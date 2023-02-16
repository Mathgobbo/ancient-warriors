import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import AncientWarriors from "../contracts/AncientWarriors.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

/// This script uses the NFTMinter resource to mint a new NFT
/// It must be run with the account that has the minter resource
/// stored in /storage/NFTMinter

transaction(
    recipient: Address
) {

    /// Reference to the receiver's collection
    let recipientCollectionRef: &{NonFungibleToken.CollectionPublic}

    /// Previous NFT ID before the transaction executes
    let mintingIDBefore: UInt64

    prepare(signer: AuthAccount) {
        self.mintingIDBefore = AncientWarriors.totalSupply

        // Borrow the recipient's public NFT collection reference
        self.recipientCollectionRef = getAccount(recipient)
            .getCapability(AncientWarriors.CollectionPublicPath)
            .borrow<&{NonFungibleToken.CollectionPublic}>()
            ?? panic("Could not get receiver reference to the NFT Collection")
    }

    execute {


        // Mint the NFT and deposit it to the recipient's collection
        AncientWarriors.mintNFT(
            recipient: self.recipientCollectionRef,
            name: "Gengis Khan",
            description: "Supreme Leader from the BlaBla empire",
            thumbnail: "https://ciberia.com.br/wp-content/uploads/2017/02/34a0b5a956442813b8a795f5e068a11d-783x450.jpeg",
            civilization: AncientWarriors.Civilization.Chinese
        )
    }

    post {
        self.recipientCollectionRef.getIDs().contains(self.mintingIDBefore): "The next NFT ID should have been minted and delivered"
        AncientWarriors.totalSupply == self.mintingIDBefore + 1: "The total supply should have been increased by 1"
    }
}
 