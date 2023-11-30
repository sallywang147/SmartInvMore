pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./Libraries/VeriSolContracts.sol";

//GovernorCompatibilityBravo is the buggy contract
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) 
            return 0;
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


contract GovernorCompatibilityBravo {
     
    struct Receipt {
        bool hasVoted;
        uint8 support;
        uint96 votes;
    }
      struct ProposalDetails {
        address proposer;
        address[] targets;
        uint256[] values;
        string[] signatures;
        bytes[] calldatas;
        uint256 forVotes;
        uint256 againstVotes;
        uint256 abstainVotes;
        mapping(address => Receipt) receipts;
        bytes32 descriptionHash;
          }
     mapping(uint256 => ProposalDetails) private _proposalDetails;

    
    function hashProposal(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    ) public returns (uint256) {
        return uint256(keccak256(abi.encode(targets, values, calldatas, descriptionHash)));
    }

    function _storeProposal(
        address proposer,
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) private {
        //inferred: 
        assert(signatures.length == calldatas.length);
        bytes32 descriptionHash = keccak256(bytes(description));
        uint256 proposalId = hashProposal(targets, values, calldatas, descriptionHash);
        ProposalDetails storage details = _proposalDetails[proposalId];
        if (details.descriptionHash == bytes32(0)) {
            details.proposer = proposer;
            details.targets = targets;
            details.values = values;
            details.signatures = signatures;
            details.calldatas = calldatas;
            details.descriptionHash = descriptionHash;
        }
    }

    function propose(
        address[] memory targets,
        uint256[] memory values,
        string[] memory signatures,
        bytes[] memory calldatas,
        string memory description
    ) public returns (uint256) {
       //inferred: 
        assert(signatures.length == calldatas.length);
       // require(signatures.length == calldatas.length, "GovernorBravo: invalid signatures length");
        // Stores the full proposal and fallback to the public (possibly overridden) propose. The fallback is done
        // after the full proposal is stored, so the store operation included in the fallback will be skipped. Here we
        // call `propose` and not `super.propose` to make sure if a child contract override `propose`, whatever code
        // is added there is also executed when calling this alternative interface.
        _storeProposal(msg.sender, targets, values, signatures, calldatas, description);
        return propose(targets, values, signatures, calldatas, description);
    }



    function _encodeCalldata(
        string[] memory signatures,
        bytes[] memory calldatas
    ) private pure returns (bytes[] memory) {
        bytes[] memory fullcalldatas = new bytes[](calldatas.length);
        for (uint256 i = 0; i < fullcalldatas.length; ++i) {
            fullcalldatas[i] = bytes(signatures[i]).length == 0
                ? calldatas[i]
                : abi.encodePacked(bytes4(keccak256(bytes(signatures[i]))), calldatas[i]);
        }

        return fullcalldatas;
    }



    function _getProposalParameters(
        uint256 proposalId
    )
        private
        view
        returns (address[] memory targets, uint256[] memory values, bytes[] memory calldatas, bytes32 descriptionHash)
    {
        ProposalDetails storage details = _proposalDetails[proposalId];
        return (
            details.targets,
            details.values,
            _encodeCalldata(details.signatures, details.calldatas),
            details.descriptionHash
        );
    }


}


















 