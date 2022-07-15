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
    const [owner, addr1, addr2, addr3, addr4] = await hre.ethers.getSigners();
    // console.log(owner.address, addr1.address, addr2.address);

    // sb


    const Nft = await hre.ethers.getContractFactory("NftRight");
    const nft = await Nft.deploy("XP721", "AAA", "BBB", "123");
    await nft.deployed();
    console.log("nft address", nft.address);
    console.log("deploy success");

    const SB = await hre.ethers.getContractFactory("SB");
    const sb = await SB.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    await sb.deployed();
    await sb.connect(owner).approve(nft.address, 1000e8);
    console.log("       sb address", sb.address);

    await nft.connect(owner).contractorMint([addr2.address, addr2.address], [1, 2], [sb.address, "0x0000000000000000000000000000000000000000"]);
    await nft.connect(addr2).contractorMintTo([addr3.address, addr4.address], [1, 1], [3, 4]);
    expect(await nft.balanceOf(owner.address, 1)).to.equal(1);
    expect(await nft.balanceOf(owner.address, 2)).to.equal(1);
    expect(await nft.balanceOf(addr2.address, 1)).to.equal(1);
    expect(await nft.balanceOf(addr2.address, 2)).to.equal(1);
    expect(await nft.balanceOf(addr3.address, 1)).to.equal(3);
    expect(await nft.balanceOf(addr4.address, 1)).to.equal(4);
    console.log("mint success");

    console.log("   test deposit");
    await nft.connect(owner).depositFee([10e8.toString(), 10e18.toString()], [1, 2], [sb.address, "0x0000000000000000000000000000000000000000"], { value: ethers.utils.parseEther("10") });
    expect(await nft.provider.getBalance(nft.address)).to.equal(10e18.toString());
    expect(await sb.balanceOf(nft.address)).to.equal(10e8.toString());
    console.log("owner deposit success");
    // console.log(addr1.address);

    console.log("   test claim");
    console.log(await nft.provider.getBalance(addr1.address));
    console.log(await nft.provider.getBalance(nft.address));
    expect(await nft.connect(owner)._nonce((addr1.address), ("0x0000000000000000000000000000000000000000")) == 1);
    var v = 28;
    var r = "0xfcd0348cb3167eab145000028694e61c33d1c287d8cf94be0fbdc0a3d1c4ac2e";
    var s = "0x2abfa4838e215f84b575ddffb5a7dc82b78a4f4c7866e6c737fbc6e43995194e";
    await nft.connect(addr1).claim(
        "0x0000000000000000000000000000000000000000", addr1.address, 10e18.toString(), 1, true,
        v, r, s);
    console.log(await nft.provider.getBalance(addr1.address));
    console.log(await nft.provider.getBalance(nft.address));
    console.log(addr1.address);
    console.log("   test sb claim");
    var v = 27;
    var r = "0x0144762769601975e13da2eba32a58ac8a740c452125c172aa35c5cbcdc231cc";
    var s = "0x48d9da7f3453a4fd02a8672b8dba68a1fb379717aa2497faaeb9e0988d966b3f";
    await nft.connect(addr1).claim(
        sb.address, addr1.address, 125000000, 1, false,
        v, r, s);
    console.log("claim success");
    console.log("claim success");

    console.log("   test transferContractor")
    expect(await nft.contractor(1)).to.equal(addr2.address);
    await nft.connect(addr2).transferContractor(addr1.address, 1);
    expect(await nft.contractor(1)).to.equal(addr1.address);
    console.log("    transferContractor success")
    // expect(await nft.provider.getBalance(nftmarket.address)).to.equal(15e17.toString());

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
