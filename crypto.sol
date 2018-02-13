pragma solidity ^0.4.18;

contract SimpleStorage {
    address storedData;
    function set(address x) {
        storedData = x;
    }
    function get() constant returns (address retVal) {
        return storedData;
    }
}
contract LegacyTree {
    struct Node {
        address parent;
        address left;
        address right;
        address owner;
        uint64 depth;
    }

    struct Tree {
        address root;
        mapping(address => Node) items;
    }

    event Withdraw(address from);

    address constant rootAddress = 0x128BB7821371Ef65Dfc6A9A0153121B3B3218deb;
    mapping(address => Node) initialItems;
    Tree private legacyTree = Tree({root:rootAddress});
    // legacyTree.root = rootAddress;

    mapping (address => uint) pendingWithdrawals;

    // // TODO: make accessible to me only
    function initialise() {
        legacyTree.items[rootAddress] = Node({parent:address(0), right: address(0), left: address(0), owner:rootAddress, depth:0});
    }

    function acquireLeftLegacy(address parentAddress) payable {
        require(legacyTree.items[parentAddress].left == 0x0000000000000000000000000000000000000000);
        payParents(parentAddress);
        addLeftHeir(parentAddress);
    }

    function acquireRightLegacy(address parentAddress) payable {
        require(legacyTree.items[parentAddress].right == 0x0000000000000000000000000000000000000000);
        payParents(parentAddress);
        addRightHeir(parentAddress);
    }

    function payParents(address parentAddress) internal {
        require(msg.value == calculatePriceChild(parentAddress));
        uint64 maxDepth = legacyTree.items[parentAddress].depth;
        address currentNode = parentAddress;

        do {
            uint64 currentDepth = legacyTree.items[currentNode].depth;
            pendingWithdrawals[currentNode] += msg.value / 2**(maxDepth - currentDepth + 1);
            currentNode = legacyTree.items[currentNode].parent;
        } while(currentDepth != 0);
    }

    function calculatePriceChild(address parentAddress) internal returns(uint64 price) {
        price = 1000000000000000000;
    }

    function withdraw() public {
        uint amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;

        msg.sender.transfer(amount);
    }

    function addLeftHeir(address parentAddress) internal {
        legacyTree.items[parentAddress].left = msg.sender;
        createNode(msg.sender, parentAddress);
    }

    function addRightHeir(address parentAddress) internal {
        legacyTree.items[parentAddress].right = msg.sender;
        createNode(msg.sender, parentAddress);
    }

    function createNode(address newAddress, address parentAddress) internal {
        legacyTree.items[newAddress].parent = parentAddress;
        legacyTree.items[newAddress].owner = newAddress;
        legacyTree.items[newAddress].depth = legacyTree.items[parentAddress].depth + 1;
    }

    function getNode(address currentAddress) constant returns (address parent, address left, address right, address owner, uint64 depth) {
        parent = legacyTree.items[currentAddress].parent;
        left = legacyTree.items[currentAddress].left;
        right = legacyTree.items[currentAddress].right;
        owner = legacyTree.items[currentAddress].owner;
        depth = legacyTree.items[currentAddress].depth;
    }

    // function getTree() constant returns (address[] addresses) {
    //     addresses = new address[](10);
    //     uint64 i = 0;
    //     address[] memory currentNodes = new address[](10);
    //     currentNodes[0] = legacyTree.root;
    //     bool continueWhile = true;

    //     while(continueWhile) {
    //         continueWhile = false;
    //         address[] memory temporaryCurrentNodes = currentNodes;
    //         currentNodes = new address[](10);
    //         i = 0;
    //         for(uint64 j=0; j <  temporaryCurrentNodes.length; j++) {
    //             if(temporaryCurrentNodes[j] != address(0)) {
    //                 address leftAddress = legacyTree.items[temporaryCurrentNodes[j]].left;
    //                 address rightAddress = legacyTree.items[temporaryCurrentNodes[j]].right;
    //                 if(leftAddress != address(0)) {
    //                     addresses[j] = leftAddress;
    //                     currentNodes[i] = leftAddress;
    //                     i++;
    //                     continueWhile = true;
    //                 } else if (rightAddress != address(0)) {
    //                     addresses[j] = rightAddress;
    //                     currentNodes[i] = rightAddress;
    //                     i++;
    //                     continueWhile = true;
    //                 }
    //             }
    //         }
    //     }

    //     // for(uint i = 0; i < addresses.length; i++){
    //     //     if(addressLUT.length == i + 1) {
    //     //         addresses[i] = legacyTree.items[addressLUT[i]].owner;
    //     //     }
    //     // }
    //     return addresses;
    // }
}