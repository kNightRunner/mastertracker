const { ethers } = require("hardhat");

async function main() {
  const emision = ethers.utils.parseEther("1000");

  const MasterTracker = await ethers.getContractFactory("MasterTracker");

  const masterTracker = await MasterTracker.deploy();

  await masterTracker.deployed();

  console.log("MasterTracker deployed address:", masterTracker.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

