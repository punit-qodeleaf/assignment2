const { expect } = require("chai");

describe("TokenFactory Proxy", function () {
  let TokenFactory;
  let addr1;
  let addr2;
  let addr3;
  let addrs;
  let tknftry;

  beforeEach(async function () {
    TokenFactory = await ethers.getContractFactory("TokenFactory");
    [addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    tknftry = await upgrades.deployProxy(TokenFactory, [], {initializer:'initializerFn'});
  });

  it("Returns a previously initialized value", async function () { 
    expect( await tknftry.totalTokensDeployed()).to.equal(0);
   });

  it("returns same amount total supply of token after v2 is deployed", async function () { 
    await tknftry.deployToken("Token", "tkn", 3, 10000);
    TokenInstance = await tknftry.tokenDeployed(tknftry.tokenAddress(0x01));

    await tknftry.addMinterToToken(TokenInstance, addr1.address);

    Token = await ethers.getContractFactory("Token");
    tokenDeployed = await Token.attach(TokenInstance);

    await tokenDeployed.mint(addr2.address, 100)
    expect(await tknftry.totalSupply()).to.equal(100);

    TokenFactoryV2 = await ethers.getContractFactory("TokenFactoryV2");
    tknftryV2 = await upgrades.upgradeProxy(tknftry.address, TokenFactoryV2);
    expect(await tknftryV2.totalSupply()).to.equal(100);

   })
})