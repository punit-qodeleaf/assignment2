// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const { upgrades } = require("hardhat");
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  const proxyAddress = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9;
  // We get the contract to deploy
  const TokenFactoryV2 = await hre.ethers.getContractFactory("TokenFactoryV2");
  const tknftry = await upgrades.prepareUpgrade(proxyAddress, TokenFactoryV2);

  console.log("V2 deployed to:", tknftry);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
