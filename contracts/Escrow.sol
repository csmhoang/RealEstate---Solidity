//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Định nghĩa giao diện cho chuẩn ERC721
interface IERC721 {
    // Hàm chuyển token từ địa chỉ này sang địa chỉ khác
    function transferFrom(address _from, address _to, uint256 _id) external;
}

// Định nghĩa hợp đồng Escrow
contract Escrow {
    // Địa chỉ của hợp đồng NFT
    address public nftAddress;
    // Địa chỉ của người bán, có thể nhận thanh toán
    address payable public seller;
    // Địa chỉ của người kiểm tra
    address public inspector;
    // Địa chỉ của người cho vay
    address public lender;

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmmount;
    mapping(uint256 => address) public buyer;

    // Hàm khởi tạo hợp đồng Escrow
    constructor(
        address _nftAddress, // Địa chỉ của hợp đồng NFT
        address _seller, // Địa chỉ của người bán
        address _inspector, // Địa chỉ của người kiểm tra
        address _lender // Địa chỉ của người cho vay
    ) {
        // Gán các tham số đầu vào cho các biến trạng thái
        nftAddress = _nftAddress;
        seller = payable(_seller);
        inspector = _inspector;
        lender = _lender;
    }

    // Hàm để liệt kê NFT vào hợp đồng Escrow
    function list(
        uint256 _nftID,
        address _buyer,
        uint256 _purchasePrice,
        uint256 _escrowAmmount
    ) public {
        // Chuyển NFT từ người gửi (msg.sender) vào hợp đồng Escrow
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);
        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmmount[_nftID] = _escrowAmmount;
        buyer[_nftID] = _buyer;
    }
}
