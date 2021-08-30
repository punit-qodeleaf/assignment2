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
})