// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { expect } = require("chai");
async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const [owner, addr1, addr2] = await hre.ethers.getSigners();
  // console.log(owner.address, addr1.address, addr2.address);

  // sb
  const SB = await hre.ethers.getContractFactory("SB");
  const sb = await SB.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  // console.log(sb.address);

  const Nft = await hre.ethers.getContractFactory("NFTMINT");
  const nft = await Nft.deploy(sb.address);
  console.log("nft address", nft.address);

  await nft.deployed();
  await sb.deployed();

  await sb.connect(owner).approve(nft.address, 1000e8);

  // console.log("buy city");
  // var v = 27;
  // var r = "0xdf034be053d15b038e74f344ed9da99bffacca48e2df0269d1c0356e2cb2ccff";
  // var s = "0x4b0370cd94aa0746f4944942ca547886d915f1e588f5bbe9b98492b6cee16b76";
  // var buy_way = 1;
  // var hpn = 0;
  // var vpn = 0;
  // var horizontal = 26;
  // var vertical = 26;
  // var nonce = 1;
  // await nft.connect(owner).buyCommercialCity(buy_way, hpn, vpn, horizontal, vertical, owner.address, 1000 * 1e8, nonce,
  //   v, r, s, { value: ethers.utils.parseEther("0.0300") });

  console.log("world buy");
  // var v = 28;
  // var r = "0x568747079ce13b13a885885feeebd77b4077cd2308a9d1e97042a815bc6b5bcb";
  // var s = "0x4078e7e566e11a71abce660f77242468927c5b0e66000d9d8ae7f144e794b2ef";
  var v = 28;
  var r = "0x38858aa91f0d004e54115efba4472c1fcb3cb99f1c21d9bb546d59fe7501c334";
  var s = "0x77332a3d0eac4cad2bbb24e78537acd5b9274d529345c6329e5469fa61b791a5";
  var buy_way = 4;
  var hpn = 1;
  var vpn = 1;
  var horizontal = 19;
  var vertical = 2;
  var nonce = 57;
  await nft.connect(owner).buyWorldMap(buy_way, hpn, vpn, horizontal, vertical, owner.address, nonce,
    v, r, s);

  console.log("opensea buy");
  var v = 27;
  var r = "0x05f22deadda038c8ad2c9b6844b4d26d4f2eb7f02c0c3fbd99f7d84d3ceaf0d9";
  var s = "0x6dc8cdf7e045dd57801c1128140c447a991f75ad1d63cf16978b412c9ef078e3";
  var buy_way = 5;
  var tokenid = 1;
  var nonce = 2;
  await nft.connect(owner).buyOpenSea(buy_way, tokenid, owner.address, nonce,
    v, r, s, { value: ethers.utils.parseEther("0.0300") });
  // console.log("claim eth");
  // var claim_eth_num = (0.06 * 10 ** 18).toString();
  // await nft.connect(owner).claim_eth("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", claim_eth_num);

  // console.log("claim pot");
  // var claim_pot_num = (1000 * 10 ** 8).toString();
  // await nft.connect(owner).claim_pot(claim_pot_num);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
