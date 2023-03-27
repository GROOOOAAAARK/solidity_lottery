import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("Lottery Tests", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployFixed() {
    // Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const ethPrice = "10";

    const ticketPriceWei = ethers.utils.parseEther(ethPrice);
    const maxTicketsCount = 5;

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(ethPrice, maxTicketsCount);

    await lottery.deployed();
    return { lottery, ticketPriceWei, ethPrice, maxTicketsCount, owner, otherAccount };
  }

  async function deployedWithOneTicket() {
    const [owner, otherAccount] = await ethers.getSigners();

    const ethPrice = "10";

    const ticketPriceWei = ethers.utils.parseEther(ethPrice);
    const maxTicketsCount = 1;

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(ethPrice, maxTicketsCount);

    await lottery.deployed();
    return { lottery, ticketPriceWei, ethPrice, maxTicketsCount, owner, otherAccount };
  }

  async function deployedWithTwoTickets() {
    const [owner, otherAccount] = await ethers.getSigners();

    const ethPrice = "10";

    const ticketPriceWei = ethers.utils.parseEther(ethPrice);
    const maxTicketsCount = 2;

    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy(ethPrice, maxTicketsCount);

    await lottery.deployed();
    return { lottery, ticketPriceWei, ethPrice, maxTicketsCount, owner, otherAccount };
  }



  describe("V1", function () {
    it("Should set the init parameters", async function () {
      const { lottery, ethPrice, maxTicketsCount, owner } = await loadFixture(deployFixed);


      expect(await lottery.ticketPrice()).to.equal(ethPrice);
      expect(await lottery.maxTicketCount()).to.equal(maxTicketsCount);
      expect(await lottery.state()).to.equal(0);
      expect(await lottery.owner()).to.equal(owner.address);
    });

    it("Should start the lottery", async function () {
      const { lottery } = await loadFixture(deployFixed);

      await expect(lottery.startLottery()).to.emit(lottery, "LotteryStarted");
      expect(await lottery.state()).to.equal(1);
    });

    it("Should fail if the lottery is already started", async function () {
      const { lottery, owner } = await loadFixture(deployFixed);

      await lottery.startLottery({from: owner.address});

      await expect(lottery.startLottery({from: owner.address})).to.be.revertedWith(
        "Lottery: already started or ended"
      );
    });

    it("Should fail to start the lottery if sender is not owner", async function () {
      const { lottery, otherAccount } = await loadFixture(deployFixed);

      await expect(lottery.connect(otherAccount).startLottery()).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });

    it("Should receive and store the funds for the lottery", async function () {
      const { lottery, ticketPriceWei, ethPrice, owner, otherAccount } = await loadFixture(
        deployFixed
      );

      await lottery.startLottery({from: owner.address});

      await lottery.connect(otherAccount).buyTicket({ value: ticketPriceWei});

      expect(await ethers.provider.getBalance(lottery.address)).to.equal(
        ticketPriceWei
      );
      expect(await lottery.participants()).to.contain(otherAccount.address);
      expect(await lottery.participants()).to.have.lengthOf(1);
    });

    it("Should fail if the message value isn't the one fixed in the contract", async function () {
      // We don't use the fixture here because we want a different deployment
      const { lottery, ticketPriceWei } = await loadFixture(
        deployFixed
      );

      await lottery.startLottery();

      expect(await lottery.buyTicket({ value: ticketPriceWei.add(1000)})).to.be.revertedWith(
        "Lottery: invalid ticket price"
        );
    });

    it("Should fail if the max tickets count is reached", async function () {
      const { lottery, ticketPriceWei, ethPrice, otherAccount } = await loadFixture(
        deployedWithOneTicket
      );

      await lottery.startLottery();

      await expect(await lottery.connect(otherAccount).buyTicket({ value: ticketPriceWei})).to.emit(lottery, "LotteryEnded").withArgs(otherAccount.address);
      await expect(lottery.buyTicket({ value: (ticketPriceWei)})).to.be.revertedWith(
        "Lottery: not started or ended"
      );
      expect(await lottery.state()).to.equal(2);
      expect(await ethers.provider.getBalance(lottery.address)).to.equal(
        0
      );
      expect(await ethers.provider.getBalance(lottery.address)).to.equal(0);
    });

    it("Should contain the right stakes", async function () {

      const { lottery, ticketPriceWei, ethPrice, otherAccount } = await loadFixture(
        deployedWithTwoTickets
      );

      await lottery.startLottery();

      await lottery.connect(otherAccount).buyTicket({ value: ticketPriceWei});

      expect(await lottery.stakes()).to.equal(ethPrice);
    });

    it("Should reset the lottery", async function () {
      const { lottery, ticketPriceWei, ethPrice, otherAccount } = await loadFixture(
        deployedWithOneTicket
      );

      const newTicketPrice = ethers.utils.parseEther("2");
      const newMaxTicketsCount = 5;

      await lottery.startLottery();

      await lottery.connect(otherAccount).buyTicket({ value: ticketPriceWei});

      await lottery.resetLottery(
        newTicketPrice,
        newMaxTicketsCount,
      );

      expect(await lottery.state()).to.equal(0);
      expect(await lottery.stakes()).to.equal(0);
      expect(await lottery.participants()).to.be.empty;
      expect(await lottery.ticketPrice()).to.equal(newTicketPrice);
      expect(await lottery.maxTicketCount()).to.equal(newMaxTicketsCount);
    });

    it("Should fail if the lottery is not ended", async function () {
      const { lottery, ethPrice } = await loadFixture(
        deployedWithOneTicket
      );

      await lottery.startLottery();

      await expect(lottery.resetLottery(ethPrice, 5)).to.be.revertedWith(
        "Lottery: not ended"
      );
    });

    it("Should fail if the caller is not the owner", async function () {
      const { lottery, ticketPriceWei, ethPrice, otherAccount } = await loadFixture(
        deployedWithOneTicket
      );

      await lottery.startLottery();

      await lottery.connect(otherAccount).buyTicket({ value: ticketPriceWei});

      await expect(lottery.connect(otherAccount).resetLottery(ethPrice, 5)).to.be.revertedWith(
        "Ownable: caller is not the owner"
      );
    });

    // it("Should accept fallback calls", async function () {
    //   const { lottery, ticketPriceWei, ethPrice, otherAccount } = await loadFixture(
    //     deployedWithOneTicket
    //   );

    //   await lottery.startLottery();

    //   expect(await otherAccount.sendTransaction({to: lottery.address, value: ticketPriceWei, gasLimit: 30000000})).to.emit(lottery, "TicketBought").withArgs(otherAccount.address, ticketPriceWei);

    // });
  });
});
