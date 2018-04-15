pragma solidity ^0.4.17;

/*
Autor: Javier Guajardo
Twitter: @EthereumChile
Website: https://ethereumchile.cl
*/

contract DecentralizedSocialNetwork {

    address public owner;
    uint public securityFee = 10000000000000000; // 0.001 ETH in WEI (We use it in Rinkeby)

    struct Post {

        address publisher;
        string message;
        uint date;
        address[] likesList;
        address[] dislikesList;
        mapping(address => bool) likes;
        mapping(address => bool) dislikes;
        bool status;

    }

    struct Profile {

        uint _yearsOld;
        string name;
        string description;
        uint followers;
        uint following;
        uint likesCounter;
        uint dislikesCounter;
        bool status;
        uint postsCounter;
        Post[] posts;
        mapping(address => bool) friends;

    }

    mapping(address => Profile) public profiles;
    mapping(address => mapping(address => bool)) private pendingRequests;
    mapping(address => mapping(address => bool)) private likes;
    mapping(address => mapping(address => bool)) private dislikes;

    modifier onlyOwner {

        require(msg.sender == owner);
        _;

    }

    modifier onlyRegistered {

        require(profiles[msg.sender].status);
        _;

    }

    modifier pleasePayItsFree { // It never hurts in Rinkeby

        require(msg.value == securityFee);
        _; 

    }

    modifier mutualFriends (address _friendsAccount) {

        require(profiles[msg.sender].friends[_friendsAccount] && profiles[_friendsAccount].friends[msg.sender]);
        _;

    }

    modifier notLikedYet (address _friendsAccount, uint numberPost) {

        require(profiles[_friendsAccount].posts[numberPost].likes[msg.sender] == false);
        _;

    }

    modifier notDislikedYet (address _friendsAccount, uint numberPost) {

        require(profiles[_friendsAccount].posts[numberPost].dislikes[msg.sender] == false);
        _;

    }

    modifier postIsActive (address _friendsAccount, uint numberPost) {

        require(profiles[_friendsAccount].posts[numberPost].status);
        _;

    }
    
    function DecentralizedSocialNetwork () public {

        owner = msg.sender;
    
    }

    function changeFee (uint _fee) public onlyOwner {

        securityFee = _fee; // fee in WEI when Smart Contract is deployed in Testnets.
    
    }

    function createAccount (uint _yearsOld, string _name, string _description) public payable {
        // you can add pleasePayItsFree modifier when it's in Testnet.
        bool status = profiles[msg.sender].status;
        if (status) // if profile exists...

            revert();
        
        profiles[msg.sender].status = true;
        profiles[msg.sender].name = _name;
        profiles[msg.sender]._yearsOld = _yearsOld;
        profiles[msg.sender].description = _description;

    }
    
    function addFriend (address _friendsAccount) public onlyRegistered {
        // you can add pleasePayItsFree modifier when it's in Testnet.
        require(!profiles[msg.sender].friends[_friendsAccount]); // require not friends currently
        profiles[msg.sender].friends[_friendsAccount] = false;
        profiles[_friendsAccount].friends[msg.sender] = false;
        pendingRequests[_friendsAccount][msg.sender] = true;
        
    }

    function approveRequest (address _friendsAccount) public onlyRegistered {
        // you can add pleasePayItsFree modifier when it's in Testnet.
        require(
            !profiles[msg.sender].friends[_friendsAccount] &&
            pendingRequests[msg.sender][_friendsAccount] == true
            ); 
        profiles[msg.sender].friends[_friendsAccount] = true;
        profiles[_friendsAccount].friends[msg.sender] = true;
        delete pendingRequests[_friendsAccount][msg.sender];

    }

    function postInFriendsWall (address _friendsAccount, string _message) public payable onlyRegistered
        mutualFriends (_friendsAccount) {
        // you can add pleasePayItsFree modifier when it's in Testnet.

        Post memory _post;
        _post.message = _message;
        _post.date = now;
        _post.publisher = msg.sender;
        _post.status = true;
        profiles[_friendsAccount].posts.push(_post);
        profiles[_friendsAccount].postsCounter++;

    }

    function likeFriendsPost (address _friendsAccount, uint numberPost) public 
        mutualFriends (_friendsAccount) postIsActive (_friendsAccount, numberPost)
        notLikedYet (_friendsAccount, numberPost) {
        // you can add pleasePayItsFree modifier when it's in Testnet.

        profiles[_friendsAccount].posts[numberPost].likes[msg.sender] = true;

    }

    function dislikeFriendsPost (address _friendsAccount, uint numberPost) public 
        mutualFriends (_friendsAccount) postIsActive (_friendsAccount, numberPost)
        notDislikedYet (_friendsAccount, numberPost) {
        // you can add pleasePayItsFree modifier when it's in Testnet.

        profiles[_friendsAccount].posts[numberPost].dislikes[msg.sender] = true;

    }

}
