const { expect, should } = require("chai");
const chai = require("chai");
chai.use(require("chai-events"));
const EventEmitter = require("events");

describe("Token", function () {

  let emitter;
  let Token;
  let owner;
  let minter;
  let burner;
  let addrs;
  let tkn;

  beforeEach(async function () {
    emitter = new EventEmitter();
    Token = await ethers.getContractFactory("Token");
    [owner, minter, burner, ...addrs] = await ethers.getSigners();

    tkn = await Token.deploy("Token", "tkn", 3, 10000);
  })

  it("only owner should assign roles", async function () {
    await tkn.addMinter(minter.address);
    expect(await tkn.hasRole(await tkn.minterRole(), minter.address)).to.equal(true);

    await tkn.addBurner(burner.address);
    expect(await tkn.hasRole(await tkn.burnerRole(), burner.address)).to.equal(true);

    await expect(tkn.connect(minter).addMinter(minter.address)).to.be.reverted;
  });

  it("only minter should be able to mint", async function () {
    await tkn.addMinter(minter.address);
    await tkn.connect(minter).mint(burner.address, 1000);
    expect(await tkn.balanceOf(burner.address)).to.equal(1000);

    await expect(tkn.mint(burner.address)).to.be.reverted;
  });

  it("pause should function correctly and could be called only by owner", async function () {
    await expect(tkn.connect(minter).pause()).to.be.reverted;

    const pause_ = await tkn.pause();
    await pause_.wait();
    emitter.emit("Paused");
    await expect(tkn.connect(minter).transfer(burner.address, 500)).to.be.reverted;
  });

  it("should burn and could be called by only burner", async function () {
    await tkn.addBurner(burner.address);
    await tkn.addMinter(minter.address);
    await tkn.connect(minter).mint(burner.address, 1000);

    await expect(tkn.burnFrom(minter.address, 500)).to.be.reverted;

    await tkn.connect(burner).burnFrom(burner.address, 500);
    expect(await tkn.balanceOf(burner.address)).to.equal(500);
  });

  it("should not mint more than capped amount", async function () {
    await tkn.addMinter(minter.address);

    await expect(tkn.connect(minter).mint(burner.address, 100000)).to.be.revertedWith("ERC20Capped: cap exceeded");
  });

  it("should transfer when not paused", async function () {
    await tkn.addMinter(minter.address);
    await tkn.connect(minter).mint(burner.address, 1000);
    await tkn.connect(burner).transfer(minter.address, 500);

    emitter.emit("Transfer");

    expect(await tkn.balanceOf(minter.address)).to.equal(500);
  })
});
