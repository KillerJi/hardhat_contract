// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");
const { expect } = require("chai");
async function main() {

    const [owner, addr1, addr2] = await hre.ethers.getSigners();

    // await sb.connect(owner).approve(nft.address, 1000e8);

    // deploy
    console.log("       deploy");
    const SB = await hre.ethers.getContractFactory("SB");
    const sb = await SB.deploy("0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
    await sb.connect(owner).transfer(addr1.address, 10000e8);
    console.log("       sb address", sb.address);

    const Order = await hre.ethers.getContractFactory("Order");
    const order = await Order.connect(owner).deploy();
    expect(await order.owner()).to.equal(owner.address);
    console.log("       order address", order.address);

    const Nft = await hre.ethers.getContractFactory("XPNFT");
    const nft = await Nft.deploy("XPNFT", "XP", "www.sb.com", order.address);
    console.log("       nft address", nft.address);

    const Nft721 = await hre.ethers.getContractFactory("NFT");
    const nft721 = await Nft721.connect(owner).deploy();
    console.log("       nft721 address", nft721.address);

    const Nftmarket = await hre.ethers.getContractFactory("NFTMarket");
    const nftmarket = await Nftmarket.deploy("XP721", order.address, [sb.address]);
    console.log("       nftmarket address", nftmarket.address);

    await sb.connect(addr1).approve(nftmarket.address, 2000e8);
    await sb.deployed();
    await order.deployed();
    await nft.deployed();
    await nftmarket.deployed();
    await order.connect(owner).transferOwnership(nftmarket.address);
    expect(await order.owner()).to.equal(nftmarket.address);

    //test add delete currency 
    console.log("       test add delete currency ");

    // console.log(await nftmarket.getBalance(owner.address));
    expect(await nftmarket.paymentCurrency(sb.address)).to.equal(true);
    await nftmarket.connect(owner).delete_currency(sb.address);
    expect(await nftmarket.paymentCurrency(sb.address)).to.equal(false);
    await nftmarket.connect(owner).add_currency(sb.address);
    expect(await nftmarket.paymentCurrency(sb.address)).to.equal(true);
    console.log("       Success");

    //test create transfer
    console.log("       test create then transfer");
    expect(await nft.creators(1)).to.equal("0x0000000000000000000000000000000000000000");
    expect(await nft.balanceOf(owner.address, 1)).to.equal(0);
    await nft.connect(owner).create(owner.address);
    expect(await nft.creators(1)).to.equal(owner.address);
    expect(await nft.balanceOf(owner.address, 1)).to.equal(1);
    expect(await nft.balanceOf(addr1.address, 1)).to.equal(0);
    var data = [];
    await nft.connect(owner).safeTransferFrom(owner.address, addr1.address, 1, 1, data);
    expect(await nft.creators(1)).to.equal(owner.address);
    expect(await nft.balanceOf(owner.address, 1)).to.equal(0);
    expect(await nft.balanceOf(addr1.address, 1)).to.equal(1);
    //err
    // await nft.connect(owner).transfer_nft(addr1.address, 1, _date);
    console.log("       Success");

    //test settlementfee
    console.log("       test settlementfee");
    await nft.connect(owner).setMarketAdd(nftmarket.address);
    expect(await nft.payStatus(owner.address)).to.equal(false);
    expect(await nft.isApprovedForAll(owner.address, nftmarket.address)).to.equal(false);
    await nft.connect(owner).settlementfee({ value: ethers.utils.parseEther("0.0300") });
    expect(await nft.payStatus(owner.address)).to.equal(true);
    expect(await nft.isApprovedForAll(owner.address, nftmarket.address)).to.equal(true);
    console.log("       Success");

    //test takedown
    console.log("       test takedown");
    console.log("addr1.address", addr1.address);
    expect(await order.saleStatus(1)).to.equal(false);
    var v = 27;
    var r = "0xa9947bd8778b85f76a437dfccf432b0da0f844499809bee5a0e0b3ac4f451a63";
    var s = "0x575fecf8ff5fccd2abfb6bba05a2b0a472d4c9126e21b93d8f23b5c6ae3e48be";
    await nftmarket.connect(addr1).takeDown(addr1.address, 1, r, s, v);
    expect(await order.saleStatus(1)).to.equal(true);
    console.log("       Success");

    //test buyOrder
    console.log("       test buyOrder");
    expect(await sb.connect(addr1).balanceOf(addr1.address)).to.equal(1000000000000);
    expect(await sb.connect(addr1).balanceOf(owner.address)).to.equal(0);
    expect(await sb.connect(addr1).balanceOf(nftmarket.address)).to.equal(0);
    await nft.connect(owner).create(owner.address);
    var v = 27;
    var r = "0x7aa71272355d1829047bf1fdfa53eecf3c585b56393d7897c80d778791a98d36";
    var s = "0x2f5076b1d2c358d48bef46bd0a2f4d8abf7dcf6a042d73c5f1ef5db742cac810";
    console.log("       Success1");
    await nftmarket.connect(addr1).buyOrder({
        id: 2, tokenid: 2, price: 1000e8, token: sb.address,
        owner: owner.address, creator: owner.address, to: addr1.address, createdate: 1111111,
        enddate: 11111111111, original: false
    },
        v, r, s, nft.address, true);
    expect(await sb.connect(addr1).balanceOf(addr1.address)).to.equal(900000000000);
    expect(await sb.connect(addr1).balanceOf(owner.address)).to.equal(98500000000);
    expect(await sb.connect(addr1).balanceOf(nftmarket.address)).to.equal(1500000000);

    console.log("       test 721 buyOrder");
    await nft721.connect(owner).setApprovalForAll(nftmarket.address, true);
    var v = 27;
    var r = "0x4aff1ff35c6fcafffc48aae2339d948c528e244e7305d7bed6cb37fe573cbe40";
    var s = "0x68761b5b2a7c6954eda69d4d813c3b288fdf7bf7599237d5a6901c321433ca5f";
    await nftmarket.connect(addr1).buyOrder({
        id: 3, tokenid: 1, price: 1000e8, token: sb.address,
        owner: owner.address, creator: owner.address, to: addr1.address, createdate: 1111111,
        enddate: 11111111111, original: false
    },
        v, r, s, nft721.address, false);
    expect(await sb.connect(addr1).balanceOf(addr1.address)).to.equal(800000000000);
    expect(await sb.connect(addr1).balanceOf(owner.address)).to.equal(197000000000);
    expect(await sb.connect(addr1).balanceOf(nftmarket.address)).to.equal(3000000000);
    console.log("       Success");

    //test claim
    console.log("       test claim");
    expect(await sb.connect(addr1).balanceOf(owner.address)).to.equal(197000000000);
    expect(await sb.connect(addr1).balanceOf(nftmarket.address)).to.equal(3000000000);
    await nftmarket.connect(owner).claim_other(sb.address, 3000000000);
    expect(await sb.connect(addr1).balanceOf(owner.address)).to.equal(200000000000);
    expect(await sb.connect(addr1).balanceOf(nftmarket.address)).to.equal(0);

    var claim_eth_num = (0.03 * 10 ** 18).toString();
    await nft.connect(owner).claim(owner.address, claim_eth_num);

    //test original order 
    console.log("       test buyOriginalOrder");
    expect(await nftmarket.provider.getBalance(nftmarket.address)).to.equal(0);
    await nft.connect(owner).create(owner.address);
    var v = 28;
    var r = "0x840f06ed441f52b23eb7547fdec98e88543e5eabbe0f01fd001585cc6abc0de5";
    var s = "0x17d80d1eb66c1d8577508222a24f0858037b7079659b3adf18220a2d06fd1ff5";
    await nftmarket.connect(addr1).buyOrder({
        id: 4, tokenid: 3, price: 100e18.toString(), token: "0x0000000000000000000000000000000000000000",
        owner: owner.address, creator: owner.address, to: addr1.address, createdate: 1111111,
        enddate: 11111111111, original: true
    },
        v, r, s, nft.address, true, { value: ethers.utils.parseEther("100") });
    expect(await nftmarket.provider.getBalance(nftmarket.address)).to.equal(15e17.toString());
    console.log("       Success");

    //test original 721 order 
    console.log("       test 721 buyOriginalOrder");
    var v = 28;
    var r = "0x18533614f0df895e9f4e2cdd92009c9a0b81468200c490c01e80f961168d3e65";
    var s = "0x74fd16b3e93a61c9facdeb9708cfd802cabea37067d7fae4227bf82d861c7b36";
    await nftmarket.connect(addr1).buyOrder({
        id: 5, tokenid: 3, price: 100e18.toString(), token: "0x0000000000000000000000000000000000000000",
        owner: owner.address, creator: owner.address, to: addr1.address, createdate: 1111111,
        enddate: 11111111111, original: true
    },
        v, r, s, nft721.address, false, { value: ethers.utils.parseEther("100") });
    expect(await nftmarket.provider.getBalance(nftmarket.address)).to.equal(30e17.toString());
    console.log("       Success");

    //test claim eth
    console.log("       test claim eth");
    expect(await nftmarket.provider.getBalance(nftmarket.address)).to.equal(30e17.toString());
    await nftmarket.connect(owner).claim(owner.address, 30e17.toString());
    expect(await nftmarket.provider.getBalance(nftmarket.address)).to.equal(0);
    console.log("       Success");

    //test set fee
    console.log("       test set fee");
    expect(await nftmarket.connect(owner).creatorFee()).to.equal(100);
    expect(await nftmarket.connect(owner).platformFee()).to.equal(150);
    expect(await nft.connect(owner).listingFee()).to.equal(0.03e18.toString());

    await nft.connect(owner).set_listingFee(0.02e18.toString());
    expect(await nft.connect(owner).listingFee()).to.equal(0.02e18.toString());

    console.log("       Success");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
