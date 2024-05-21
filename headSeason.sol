// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./validatorsPool.sol";
import "./land.sol";
import "./sales.sol";
import "./candidate.sol";
interface ExmodulesMarketPlace {
    function updateValidatorsPoolContractAddress(address _validatorsPool) external;
    function updateTax(uint256 _taxAmount) external;
}

interface NFTSales{
    function updateValidatorsPoolContractAddress(address _validatorsPool)external;
    function updateTax(uint256 _taxAmount) external;
}
contract HeadSeason{
    //................events....................
    event CreatedSeason(address validatorPoolAddress,address candidateAddress,string _trackId);
    //.............varaibles..............//
    uint256 public currentTax;
    address public owner;
    uint256 public totalSeasons=0;
    LandContract public landContract;
    Sales public salesContract;
    address public token;
    address public stakeContractAddress;
    ExmodulesMarketPlace public nftMarketContract;
    NFTSales public salesNFTContract;
    address public usdtContractAddress;
    //...........................enums.......................//
    enum accessibleFunctions{
        createSeason
    }
    //..............................structs............................//
    struct seasonDetails{
        uint256 startDate;
        uint256 endDate;
        uint256 ValidatorsVotingStartTime;
        uint256 ValidatorsVotingEndTime;
        uint256 candidatingStartTime;
        uint256 candidatingEndTime;
        address ValidatorsPoolContractAddress;
        address CandidateContractAddress;
        uint256 candidatingCost;
    }
    //...................maps..........................//
    mapping (uint256 => seasonDetails) public seasons;
    mapping(address=>mapping (uint8 => bool))public operators;
    //..........................modifiers.............................//
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner of the contract");
        _;
    }

    modifier onlySeasonContract(){
        require(msg.sender==seasons[totalSeasons].ValidatorsPoolContractAddress,"this function can call by the current season contract");
        _;
    }

    modifier onlyOwnerAndOperators(uint8 _accessibleFunctionsId){
        if(msg.sender==owner || operators[msg.sender][_accessibleFunctionsId]){
            _;
        }
        else{
            revert("You are not the owner of the contract or you don't have access to call this function");
        }
    }

    constructor(uint256 _currentTax,address _salesContractAddress,address _landContractAddress,address _token,address _usdtContractAddress
    ){
        owner=msg.sender;
        currentTax=_currentTax;
        landContract=LandContract(_landContractAddress);
        salesContract=Sales(_salesContractAddress);
        token=_token;
        usdtContractAddress=_usdtContractAddress;
    }

    function createSeason(uint256 _seasonId,uint256 _startDate,uint256 _endDate,uint256 _candidatingStartTime,uint256 _candidatingEndTime,uint256 _ValidatorsVotingStartTime,uint256 _ValidatorsVotingEndTime,uint256 _candidatingCost,string memory _trackId)public onlyOwnerAndOperators(0){
        if(totalSeasons==0){
            //...................create related contracts for season.............................
            Candidate newCandidateContract=new Candidate(_candidatingStartTime,_candidatingEndTime,stakeContractAddress,_candidatingCost,usdtContractAddress,owner);
            ValidatorsPool newValidatorsPoolContract=new ValidatorsPool(token,address(landContract),address(salesContract),currentTax,_ValidatorsVotingStartTime,_ValidatorsVotingEndTime,owner,address(newCandidateContract),address(this),stakeContractAddress
            ,address(nftMarketContract),address(salesNFTContract)
            );

            //.......................create Season..........................
            seasons[_seasonId]=seasonDetails(_startDate,_endDate,_ValidatorsVotingStartTime,_ValidatorsVotingEndTime,_candidatingStartTime,_candidatingEndTime,address(newValidatorsPoolContract),address(newCandidateContract),_candidatingCost);
            totalSeasons++;
            landContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
            salesContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
            if(address(nftMarketContract) !=address(0) && address(salesNFTContract) !=address(0)){
                nftMarketContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
                salesNFTContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
            }
            emit CreatedSeason(address(newValidatorsPoolContract),address(newCandidateContract),_trackId);
        }
        else{
            if(seasons[totalSeasons].endDate<block.timestamp){
                //...................create related contracts for season.............................
                Candidate newCandidateContract=new Candidate(_candidatingStartTime,_candidatingEndTime,stakeContractAddress,_candidatingCost,usdtContractAddress,owner);
                ValidatorsPool newValidatorsPoolContract=new ValidatorsPool(token,address(landContract),address(salesContract),currentTax,_ValidatorsVotingStartTime,_ValidatorsVotingEndTime,owner,address(newCandidateContract),address(this),stakeContractAddress
                ,address(nftMarketContract),address(salesNFTContract)
                );
                //.......................create Season..........................
                seasons[_seasonId]=seasonDetails(_startDate,_endDate,_ValidatorsVotingStartTime,_ValidatorsVotingEndTime,_candidatingStartTime,_candidatingEndTime,address(newValidatorsPoolContract),address(newCandidateContract),_candidatingCost);
                totalSeasons++;
                landContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
                salesContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
                if(address(nftMarketContract) !=address(0) && address(salesNFTContract) !=address(0)){
                    nftMarketContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
                    salesNFTContract.updateValidatorsPoolContractAddress(address(newValidatorsPoolContract));
                }
                emit CreatedSeason(address(newValidatorsPoolContract),address(newCandidateContract),_trackId);
            }
            else{
                revert("The current season is not over yet");
            }
        }
    }
    
    function updateTax(uint256 _newTax)public onlySeasonContract(){
        currentTax=_newTax;
    }
    
    function  getSeasonRelatedContracts(uint256 _seasonId)public view returns(address validatorPoolContract,address candidateContract) {
        require(seasons[_seasonId].CandidateContractAddress!=address(0),"The season is not found");
        return (seasons[_seasonId].ValidatorsPoolContractAddress,seasons[_seasonId].CandidateContractAddress);
    }

    function addStakeContract(address _stakeContractAddress)public onlyOwner(){
        stakeContractAddress=_stakeContractAddress;
    }

    function addNftMarketContracts(address _nftMarketContractAddress,address _salesNFTContractAddress)public onlyOwner(){
        nftMarketContract=ExmodulesMarketPlace(_nftMarketContractAddress);
        salesNFTContract=NFTSales(_salesNFTContractAddress);
    }

    function addOperator(address _operator,uint8 _accessibleFunctionsId)public onlyOwner(){
        require(!operators[_operator][_accessibleFunctionsId],"operator is already added");
        operators[_operator][_accessibleFunctionsId]=true;
    }

    function removeOperator(address _operator,uint8 _accessibleFunctionsId)public onlyOwner(){
        require(operators[_operator][_accessibleFunctionsId],"operator is not found");
        delete operators[_operator][_accessibleFunctionsId];
    }

    function updateLandAndSalesContractAddress(address _salesContractAddress,address _landContractAddress)public onlyOwner(){
        landContract=LandContract(_landContractAddress);
        salesContract=Sales(_salesContractAddress);
    }
}