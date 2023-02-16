import NonFungibleToken from "../contracts/NonFungibleToken.cdc"
import AncientWarriors from "../contracts/AncientWarriors.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

/// This transaction is what an account would run
/// to set itself up to receive NFTs

transaction {

    prepare(signer: AuthAccount) {
        // Return early if the account already has a collection
        if signer.borrow<&AncientWarriors.Collection>(from: AncientWarriors.CollectionStoragePath) != nil {
            return
        }

        // Create a new empty collection
        let collection <- AncientWarriors.createEmptyCollection()

        // save it to the account
        signer.save(<-collection, to: AncientWarriors.CollectionStoragePath)

        // create a public capability for the collection
        signer.link<&{NonFungibleToken.CollectionPublic, AncientWarriors.AncientWarriorsCollectionPublic, MetadataViews.ResolverCollection}>(
            AncientWarriors.CollectionPublicPath,
            target: AncientWarriors.CollectionStoragePath
        )
    }
}