//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CreatureTD is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string public baseURI;
    uint256 public supply;
    string public baseExtension = ".json";
    string public notRevealedUri;
    uint256 public cost;
    uint256 public maxSupply = 5555;
    uint256 public maxMintQuantity;
    uint256 public nftPerAdressLimit = 500;
    bool public paused;
    bool public revealed;
    mapping(address => uint256) public addressToBalanceMinted;
    mapping(address => bool) public whitelisted;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initbaseURI,
        string memory _notRevealedURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initbaseURI);
        setNotRevealedUri(_notRevealedURI);
    }

    function mint(uint256 _mintQuantity) public payable {
        require(paused == true, "minting is paused");
        supply = totalSupply();
        uint256 mintVariants = supply + _mintQuantity;
        require(_mintQuantity > 0, "Can't mint less than 0 NFT");
        require(_mintQuantity <= maxMintQuantity, "Amount exceed maximum mint");
        require(mintVariants <= maxSupply, "exceed mint limit");

        // A user who is not the owner is expected to pay a value to be able to mint.
        if (msg.sender != owner()) {
            uint256 quantityHold = addressToBalanceMinted[msg.sender];
            require(
                quantityHold + _mintQuantity <= nftPerAdressLimit,
                "max limit per address exceeded"
            );

            require(
                msg.value >= _mintQuantity * cost,
                "Insufficient amount provided"
            );
        }

        for (uint256 i = 1; i <= _mintQuantity; i++) {
            addressToBalanceMinted[msg.sender]++;
            _safeMint(msg.sender, supply + i);
        }
    }

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }

    function setNotRevealedUri(string memory _notRevealed) public onlyOwner {
        notRevealedUri = _notRevealed;
    }

    function setPause() public onlyOwner {
        paused = !paused;
    }

    function presaleMint(uint256 amount) public payable {}


    function getNumOfNfts(address _owner) public view returns(uint256[] memory tokensIds_) {
        uint256 ownedNft = balanceOf(_owner);
        tokensIds_ = new uint256[](ownedNft);
        for (uint256 i = 0; i < ownedNft; i++) {
            tokensIds_[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokensIds_;
    }

    function setNftHolderLimit(uint256 _limit) public onlyOwner {
        nftPerAdressLimit = _limit;
    }

    function setCostForMint(uint256 _cost) public onlyOwner {
        cost = _cost;
    }

}
