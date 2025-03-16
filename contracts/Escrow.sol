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

    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }

    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }

    modifier onlyBuyer(uint256 _nftID) {
        require(msg.sender == buyer[_nftID], "Only buyer can call this method");
        _;
    }

    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

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
        uint256 _escrowAmount
    ) public payable onlySeller {
        // Chuyển NFT từ người gửi (msg.sender) vào hợp đồng Escrow
        IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);
        isListed[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        escrowAmount[_nftID] = _escrowAmount;
        buyer[_nftID] = _buyer;
    }

    function depositeEarnest(uint256 _nftID) public payable onlyBuyer(_nftID) {
        require(msg.value >= escrowAmount[_nftID]);
    }

    function updateInspectionStatus(
        uint256 _nftID,
        bool _passed
    ) public onlyInspector {
        inspectionPassed[_nftID] = _passed;
    }

    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }

    receive() external payable {}

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    // Hoàn tất giao dịch
    // => Yêu cầu trạng thái kiểm tra (thêm các mục khác ở đây, như thẩm định)
    // => Yêu cầu giao dịch được ủy quyền
    // => Yêu cầu số tiền phải chính xác
    // => Chuyển NFT cho người mua
    // => Chuyển tiền cho người bán

    function finalizeSale(uint256 _nftID) public {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);
        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}(
            ""
        );
        require(success);

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }

    function cancelSale(uint256 _nftID) public {
        if(inspectionPassed[_nftID]==false){
            payable(buyer[_nftID]).transfer(address(this).balance);
        }
    }
}
