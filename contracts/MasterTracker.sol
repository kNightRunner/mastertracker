// SPDX-License-Identifier: MIT

pragma solidity >=0.5.0 <0.9.0;
import "hardhat/console.sol";

contract MasterTracker {
    struct Asset {
        uint id;
        address owner;
        string description;
        string fullName;
        string assetSerial;
        string buyDate;
        string assetCondition;
        string soldDate;
    }
    uint public assetCount;
    mapping(uint => Asset) public assets;
    mapping(address => uint[]) public assetsByOwner;

    event AssetRegistered(uint id, address owner);
    event AssetTransferred(uint id, address from, address to);

    function registerAsset(
        string memory _description,
        string memory _fullName,
        string memory _assetSerial,
        string memory _buyDate,
        string memory _assetCondition 
        ) public {

        require(bytes(_assetSerial).length > 0, "Asset serial is required");
        require(bytes(_assetCondition).length > 0, "Asset condition is required");
        require(bytes(_buyDate).length > 0, "Buy date is required");
        require(bytes(_fullName).length > 0, "Full name is required");
        require(bytes(_description).length > 0, "Description is required");
        require(keccak256(abi.encodePacked(_assetCondition)) == keccak256(abi.encodePacked("new")) || keccak256(abi.encodePacked(_assetCondition)) == keccak256(abi.encodePacked("used")), "Asset condition must be new or used");
   
        for (uint i = 0; i < assetCount; i++) {
              console.log("Asset serial: %s", _assetSerial);
              console.log("Asset ARRAY: %s", assets[0].assetSerial);
        
            require(keccak256(abi.encodePacked(assets[i].assetSerial)) == keccak256(abi.encodePacked(_assetSerial)), "Asset serial already exists");
        }

        assetCount++;
        string memory soldDate = "Not sold yet";
        assets[assetCount] = Asset(assetCount, msg.sender, _description, _fullName, _assetSerial, _buyDate, _assetCondition, soldDate );
        assetsByOwner[msg.sender].push(assetCount);
        emit AssetRegistered(assetCount, msg.sender);
    }
//function to get the last asset id
    function getLastAssetId() public view returns (uint) {
        return assetCount;
    }
// write a view function to get all records saved in assets and assetsByOwner
    function getAssets() public view returns (Asset[] memory) {
        Asset[] memory result = new Asset[](assetCount);
        for (uint i = 0; i < assetCount; i++) {
            result[i] = assets[i + 1];
        }
        return result;
    }


function getDescriptionByAssetId(uint _id) public view returns (string memory) {
        return assets[_id].description;
    }
    function getAsset(uint _id) public view returns (Asset memory) {
        return assets[_id];
    }
    function removeAsset(uint[] memory _assets, uint _id) internal pure returns (uint[] memory) {
        uint[] memory result = new uint[](_assets.length - 1);
        uint counter = 0;
        for (uint i = 0; i < _assets.length; i++) {
            if (_assets[i] != _id) {
                result[counter] = _assets[i];
                counter++;
            }
        }
        return result;
    }
//sacar el buydate

    function transferAsset(
        address _to,
        uint _id,
        string memory _fullName,
        string memory _assetSerial,
        string memory _buyDate,
        string memory _soldDate
        ) public {
        require(_id > 0 && _id <= assetCount, "Asset does not exist");
        require(bytes(_assetSerial).length > 0, "Asset serial is required");
        require(bytes(_soldDate).length > 0, "Sold date is required");
        require(bytes(_fullName).length > 0, "Full name is required");
        //require address is not null
        require(_to != address(0), "Address is required");
        //validate the asset serial if it already exists
        for (uint i = 0; i < assetCount; i++) {
            require(keccak256(abi.encodePacked(assets[i].assetSerial)) != keccak256(abi.encodePacked(_assetSerial)), "Asset serial dont exists");
        }
        uint newRow = getLastAssetId()+1;
        assets[newRow].assetCondition = "sold";
        assets[newRow].owner = _to;
        assets[newRow].fullName = _fullName;
        assets[newRow].assetSerial = _assetSerial;
        assets[newRow].buyDate = _buyDate;
        assets[newRow].assetCondition = "used";
        assets[newRow].description = getDescriptionByAssetId(_id);
        assetsByOwner[_to].push(_id);
        emit AssetTransferred(_id, msg.sender, _to);
    }

// Devuelve los id de los objetos pertenecientes a la addres
    function getAssetsByOwner(address _owner) public view returns (Asset[] memory) {
        Asset[] memory result = new Asset[](assetsByOwner[_owner].length);
        for (uint i = 0; i < assetsByOwner[_owner].length; i++) {
            result[i] = assets[assetsByOwner[_owner][i]];
        }
        return result;
    }


//Devuelve solamente quien es la address dueño por el ID
    function getAssetById(uint _id) public view returns (uint, address, string memory, string memory ) {
        return (assets[_id].id, assets[_id].owner, assets[_id].description,assets[_id].fullName) ;
    }

//POr address te devuelve un contador de objetos de esa addres
    function getAssetsByOwnerCount(address _owner) public view returns (uint) {
        return assetsByOwner[_owner].length;
    }

    function removeAssetId(uint[] storage _assetIds, uint _id) internal returns (uint[] storage) {
        for (uint i = 0; i < _assetIds.length; i++) {
            if (_assetIds[i] == _id) {
                _assetIds[i] = _assetIds[_assetIds.length - 1];
                _assetIds.pop();
                break;
            }
        }
        return _assetIds;
    }
}
