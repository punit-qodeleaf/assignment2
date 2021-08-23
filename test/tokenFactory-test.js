const { expect } = require("chai");

describe("TokenFactory", function () {

  let TokenFactory;
  let addr1;
  let addr2;
  let addr3;
  let addrs;
  let tknftry;

  beforeEach(async function () {
    TokenFactory = await ethers.getContractFactory("TokenFactory");
    [addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    tknftry = await TokenFactory.deploy();
  });

  it("should deploy token with owner as TokenFactory", async function () {
    await tknftry.deployToken("Token", "tkn", 3, 10000);
    TokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x01));

    Token = await ethers.getContractFactory("Token");
    tokenDeployed = await Token.attach(TokenInstance);

    expect(await tokenDeployed.hasRole(await tokenDeployed.DEFAULT_ADMIN_ROLE(), tknftry.address)).to.equal(true);
  });

  it("should function correctly if not paused", async function () {
    await tknftry.deployToken("Token", "tkn", 3, 10000);
    TokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x01));

    Token = await ethers.getContractFactory("Token");
    tokenDeployed = await Token.attach(TokenInstance);

    await tknftry.addMinterToToken(TokenInstance, addr1.address);
    await tokenDeployed.connect(addr1).mint(addr1.address, 100);

    await tokenDeployed.connect(addr1).transfer(addr2.address, 50);
    expect(await tokenDeployed.balanceOf(addr2.address)).to.equal(50);
  });

  it("token should not work if paused from Token Factory", async function () { 
    await tknftry.deployToken("Token", "tkn", 3, 10000);
    TokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x01));

    Token = await ethers.getContractFactory("Token");
    tokenDeployed = await Token.attach(TokenInstance);

    await tknftry.pauseToken(TokenInstance);
    await expect(tokenDeployed.balanceOf(addr2.address)).to.be.reverted;
   });

   it("should return total supply of all tokens deployed", async function () { 
    await tknftry.deployToken("Token", "tkn", 3, 10000);
    await tknftry.deployToken("ETHER", "ETH", 3, 10000);
    Token = await ethers.getContractFactory("Token");

    FirstTokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x01));
    SecondTokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x02));

    firstTokenDeployed = await Token.attach(FirstTokenInstance);
    secondTokenDeployed = await Token.attach(SecondTokenInstance);
    
    await tknftry.addMinterToToken(FirstTokenInstance, addr1.address);
    await tknftry.addMinterToToken(SecondTokenInstance, addr1.address);

    await firstTokenDeployed.connect(addr1).mint(addr1.address, 100);
    await secondTokenDeployed.connect(addr1).mint(addr1.address, 100);

    expect(await tknftry.totalSupply()).to.equal(200);
  });
})