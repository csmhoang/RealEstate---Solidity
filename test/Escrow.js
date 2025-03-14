const { expect } = require("chai");
const { ethers } = require("hardhat");

// Hàm chuyển đổi số lượng token sang đơn vị ether
const tokens = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

// Mô tả bộ kiểm thử cho hợp đồng Escrow
describe("Escrow", () => {
  let buyer, seller, inspector, lender; // Khai báo các tài khoản
  let realEstate, escrow;

  beforeEach(async () => {
    // Lấy danh sách các tài khoản (signers) từ ethers
    [buyer, seller, inspector, lender] = await ethers.getSigners();
    // Triển khai hợp đồng Real Estate
    const RealEstate = await ethers.getContractFactory("RealEstate");
    realEstate = await RealEstate.deploy();

    // Mint một token mới
    let transaction = await realEstate
      .connect(seller) // Kết nối với tài khoản người bán
      .mint(
        "http://localhost:3000/nft/1" // URI của token
      );
    await transaction.wait(); // Chờ giao dịch hoàn tất

    // Triển khai hợp đồng Escrow
    const Escrow = await ethers.getContractFactory("Escrow");
    escrow = await Escrow.deploy(
      realEstate.address, // Địa chỉ hợp đồng Real Estate
      seller.address, // Địa chỉ người bán
      inspector.address, // Địa chỉ người kiểm tra
      lender.address // Địa chỉ người cho vay
    );

    transaction = await realEstate.connect(seller).approve(escrow.address, 1);
    await transaction.wait();

    transaction = await escrow.connect(seller).list(1, buyer.address, tokens(10), tokens(5));
    await transaction.wait();
  });

  describe("Development", () => {
    it("Returns NFT address", async () => {
      const result = await escrow.nftAddress();
      expect(result).to.be.equal(realEstate.address);
    });
    it("Returns seller", async () => {
      const result = await escrow.seller();
      expect(result).to.be.equal(seller.address);
    });
    it("Returns inspector", async () => {
      const result = await escrow.inspector();
      expect(result).to.be.equal(inspector.address);
    });
    it("Returns lender", async () => {
      const result = await escrow.lender();
      expect(result).to.be.equal(lender.address);
    });
  });

  describe("Listing", () => {
    it("Updates as listed", async () => {
      const result = await escrow.isListed(1);
      expect(result).to.be.equal(true);
    });

    it("Updates ownership", async () => {
      expect(await realEstate.ownerOf(1)).to.be.equal(escrow.address);
    });
    it("Returns buyer", async () => {
      const result = await escrow.buyer(1);
      expect(result).to.be.equal(buyer.address);
    });
    it("Returns purchase ", async () => {
      const result = await escrow.purchasePrice(1);
      expect(result).to.be.equal(tokens(10));
    });
    it("Update ownership", async () => {
      const result = await escrow.escrowAmount(1);
      expect(result).to.be.equal(tokens(5));
    });
  });
});
