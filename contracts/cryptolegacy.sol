pragma solidity ^0.4.18;

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

    address owner;

    uint64 oneEther = 1000000000000000000;
    address constant rootAddress = 0x128BB7821371Ef65Dfc6A9A0153121B3B3218deb;
    mapping(address => Node) initialItems;
    Tree private legacyTree = Tree({root:rootAddress});

    mapping (address => uint) pendingWithdrawals;

    function LegacyTree() public {
        owner = msg.sender;
        legacyTree.items[rootAddress] = Node({parent:address(0), right: address(0), left: address(0), owner:rootAddress, depth:0});
    }

    function acquireLeftLegacy(address parentAddress) payable public {
        require(legacyTree.items[parentAddress].left == address(0));
        payParents(parentAddress);
        addLeftHeir(parentAddress);
    }

    function acquireRightLegacy(address parentAddress) payable public {
        require(legacyTree.items[parentAddress].right == address(0));
        payParents(parentAddress);
        addRightHeir(parentAddress);
    }

    function payParents(address parentAddress) internal {
        require(msg.value == calculatePriceChild());
        uint64 maxDepth = legacyTree.items[parentAddress].depth;
        address currentNode = parentAddress;

        do {
            uint64 currentDepth = legacyTree.items[currentNode].depth;
            pendingWithdrawals[currentNode] += msg.value / 2**(maxDepth - currentDepth + 1);
            currentNode = legacyTree.items[currentNode].parent;
        } while(currentDepth != 0);
    }

    function calculatePriceChild() internal returns(uint64 price) {
        price = oneEther / 100;
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

    function kill() public {
      if(msg.sender == owner)
         selfdestruct(owner);
    }

    function() payable {}

    function getNode(address currentAddress) constant public returns (address parent, address left, address right, address owner, uint64 depth) {
        parent = legacyTree.items[currentAddress].parent;
        left = legacyTree.items[currentAddress].left;
        right = legacyTree.items[currentAddress].right;
        owner = legacyTree.items[currentAddress].owner;
        depth = legacyTree.items[currentAddress].depth;
    }
}

