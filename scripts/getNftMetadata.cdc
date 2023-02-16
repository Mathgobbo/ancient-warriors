import AncientWarriors from "../contracts/AncientWarriors.cdc"
import MetadataViews from "../contracts/MetadataViews.cdc"

/// This script gets all the view-based metadata associated with the specified NFT
/// and returns it as a single struct

pub struct NFT {
    pub let name: String
    pub let description: String
    pub let thumbnail: String
    pub let owner: Address
    pub let type: String
    pub let externalURL: String
    pub let collectionPublicPath: PublicPath
    pub let collectionStoragePath: StoragePath
    pub let collectionProviderPath: PrivatePath
    pub let collectionPublic: String
    pub let collectionPublicLinkedType: String
    pub let collectionProviderLinkedType: String
    pub let collectionName: String
    pub let collectionDescription: String
    pub let collectionExternalURL: String
    pub let collectionSquareImage: String
    pub let collectionBannerImage: String
    pub let collectionSocials: {String: String}
    pub let traits: MetadataViews.Traits

    init(
        name: String,
        description: String,
        thumbnail: String,
        owner: Address,
        nftType: String,
        externalURL: String,
        collectionPublicPath: PublicPath,
        collectionStoragePath: StoragePath,
        collectionProviderPath: PrivatePath,
        collectionPublic: String,
        collectionPublicLinkedType: String,
        collectionProviderLinkedType: String,
        collectionName: String,
        collectionDescription: String,
        collectionExternalURL: String,
        collectionSquareImage: String,
        collectionBannerImage: String,
        collectionSocials: {String: String},
        traits: MetadataViews.Traits,
    ) {
        self.name = name
        self.description = description
        self.thumbnail = thumbnail
        self.owner = owner
        self.type = nftType
        self.externalURL = externalURL
        self.collectionPublicPath = collectionPublicPath
        self.collectionStoragePath = collectionStoragePath
        self.collectionProviderPath = collectionProviderPath
        self.collectionPublic = collectionPublic
        self.collectionPublicLinkedType = collectionPublicLinkedType
        self.collectionProviderLinkedType = collectionProviderLinkedType
        self.collectionName = collectionName
        self.collectionDescription = collectionDescription
        self.collectionExternalURL = collectionExternalURL
        self.collectionSquareImage = collectionSquareImage
        self.collectionBannerImage = collectionBannerImage
        self.collectionSocials = collectionSocials
        self.traits = traits
    }
}

pub fun main(address: Address, id: UInt64): NFT {
    let account = getAccount(address)

    let collection = account
        .getCapability(AncientWarriors.CollectionPublicPath)
        .borrow<&{AncientWarriors.AncientWarriorsCollectionPublic}>()
        ?? panic("Could not borrow a reference to the collection")

    let nft = collection.borrowAncientWarrior(id: id)!

    // Get the basic display information for this NFT
    let display = MetadataViews.getDisplay(nft)!

    let collectionDisplay = MetadataViews.getNFTCollectionDisplay(nft)!
    let nftCollectionView = MetadataViews.getNFTCollectionData(nft)!
    
    let owner: Address = nft.owner!.address!
    let nftType = nft.getType()

    let collectionSocials: {String: String} = {}
    for key in collectionDisplay.socials.keys {
        collectionSocials[key] = collectionDisplay.socials[key]!.url
    }

		let traits = MetadataViews.getTraits(nft)!

		let medias=MetadataViews.getMedias(nft)
		let license=MetadataViews.getLicense(nft)

    return NFT(
        name: display.name,
        description: display.description,
        thumbnail: display.thumbnail.uri(),
        owner: owner,
        nftType: nftType.identifier,
        externalURL: display.thumbnail.uri(),
        collectionPublicPath: nftCollectionView.publicPath,
        collectionStoragePath: nftCollectionView.storagePath,
        collectionProviderPath: nftCollectionView.providerPath,
        collectionPublic: nftCollectionView.publicCollection.identifier,
        collectionPublicLinkedType: nftCollectionView.publicLinkedType.identifier,
        collectionProviderLinkedType: nftCollectionView.providerLinkedType.identifier,
        collectionName: collectionDisplay.name,
        collectionDescription: collectionDisplay.description,
        collectionExternalURL: collectionDisplay.externalURL.url,
        collectionSquareImage: collectionDisplay.squareImage.file.uri(),
        collectionBannerImage: collectionDisplay.bannerImage.file.uri(),
        collectionSocials: collectionSocials,
        traits: traits,
    )
}