const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  const metaDataUrl = "ipfs://QmTtn1p3Z516rNSgwJrKG3ay6fhZxR7xq4rfD9uMDoSFnz/";

  const contract = await ethers.getContractFactory("WST");
  const deployedContract = await contract.deploy(metaDataUrl);
  await deployedContract.deployed();

  console.log("ADDRESS:", deployedContract.address);

  console.log("...sleeping");

  await sleep(60000);

  await hre.run("verify:verify", {
    address: deployedContract.address,
    constructorArguments: [metaDataUrl],
  });
  function sleep(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
