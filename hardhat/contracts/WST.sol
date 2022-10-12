// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WST is ERC721Enumerable, Ownable {
    using Strings for uint256;
    /**
     * @dev _baseTokenURI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`.
     */
    string _baseTokenURI;

    //  _price is the price of one LW3Punks NFT
    uint256 public _price = 0.001 ether;
    // _paused is used to pause the contract in case of an emergency
    bool public _paused;
    // max number of WST NFT
    uint256 public maxTokenIds = 10;
    // total number of tokenIds minted
    uint256 public tokenIds;

    modifier onlyWhenNotPaused() {
        require(!_paused, "Contract currently paused");
        _;
    }

    constructor(string memory baseURI) ERC721("WanShiTong", "WST") {
        _baseTokenURI = baseURI;
    }

    function mint() public payable onlyWhenNotPaused {
        require(tokenIds < maxTokenIds, "Exceeded max WST Supply");
        require(msg.value >= _price, "Ether sent not correct");
        tokenIds += 1;
        _safeMint(msg.sender, tokenIds);
    }

    /**
     * @dev _baseURI overides the Openzeppelin's ERC721 implementation which by default
     * returned an empty string for the baseURI
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseTokenURI;
    }

    /**
     * @dev tokenURI overides the Openzeppelin's ERC721 implementation for tokenURI function
     * This function returns the URI from where we can extract the metadata for a given tokenId
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI Query for nonexistent token"
        );

        string memory baseURI = _baseURI();
        // Here it checks if the length of the baseURI is greater than 0, if it is, return the baseURI and attach the tokenId and `.json` to it so that it knows the location of the metadata json file for a given tokenId stored on IPFS
        // If baseURI is empty return an empty string
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function setPaused(bool _val) public onlyOwner {
        _paused = _val;
    }

    /**
     * @dev withdraw sends all the ether in the contract
     * to the owner of the contract
     */
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send ether");
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}
