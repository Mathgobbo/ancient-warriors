

import NonFungibleToken from "./NonFungibleToken.cdc"
import MetadataViews from "./MetadataViews.cdc"

 pub contract AncientWarriors: NonFungibleToken {
    /// Total supply of ExampleNFTs in existence
    pub var totalSupply: UInt64

    /// The event that is emitted when the contract is created
    pub event ContractInitialized()

    /// The event that is emitted when an NFT is withdrawn from a Collection
    pub event Withdraw(id: UInt64, from: Address?)

    /// The event that is emitted when an NFT is deposited to a Collection
    pub event Deposit(id: UInt64, to: Address?)

    /// Storage and Public Paths
    pub let CollectionStoragePath: StoragePath
    pub let CollectionPublicPath: PublicPath

    /// Enum to save Civilization: String
    pub enum Civilization: UInt8 {
        pub case Chinese
        pub case Roman
        pub case Egyptian
    }

    /// ---------------

    /// Ancient Warrior NFT
    pub resource NFT: NonFungibleToken.INFT, MetadataViews.Resolver {
      pub let id: UInt64
      pub let name: String
      pub let description: String
      pub let thumbnail: String
      access(self) let metadata: {String: AnyStruct}

       init(
            id: UInt64,
            name: String,
            description: String,
            thumbnail: String,
            metadata: {String: AnyStruct},
        ) {
            self.id = id
            self.name = name
            self.description = description
            self.thumbnail = thumbnail
            self.metadata = metadata
        }

         /// Function that returns all the Metadata Views implemented by a Non Fungible Token
        ///
        /// @return An array of Types defining the implemented views. This value will be used by
        ///         developers to know which parameter to pass to the resolveView() method.
        ///
        pub fun getViews(): [Type] {
            return [
                Type<MetadataViews.Display>(),
                Type<MetadataViews.NFTCollectionData>(),
                Type<MetadataViews.NFTCollectionDisplay>(),
                Type<MetadataViews.Traits>()
            ]
        }

        /// Function to get Civilization Rarity
        pub fun getCivilizationRarity(_ civilization: UInt8?): MetadataViews.Rarity? {
            switch civilization{
                case Civilization.Chinese.rawValue:
                    return MetadataViews.Rarity(score: 60.0, max: 100.0, description: "Normal")
                case Civilization.Egyptian.rawValue:
                    return MetadataViews.Rarity(score: 80.0, max: 100.0, description: "Rare")
                case Civilization.Roman.rawValue:
                    return MetadataViews.Rarity(score: 75.0, max: 100.0, description: "Rare")
            }
            return nil
        }

         /// Function that resolves a metadata view for this token.
        ///
        /// @param view: The Type of the desired view.
        /// @return A structure representing the requested view.
        ///
        pub fun resolveView(_ view: Type): AnyStruct? {
          switch view {
            case Type<MetadataViews.Display>():
              return MetadataViews.Display(
                        name: self.name,
                        description: self.description,
                        thumbnail: MetadataViews.HTTPFile(
                            url: self.thumbnail
                        )
                    )
            case Type<MetadataViews.NFTCollectionDisplay>():
                var imageUrl = "https://images.fineartamerica.com/images/artworkimages/mediumlarge/1/ancient-warriors-arturas-slapsys.jpg"
                let media = MetadataViews.Media(
                    file: MetadataViews.HTTPFile(
                        url: imageUrl
                    ),
                    mediaType: "image/jpg"
                )
                return MetadataViews.NFTCollectionDisplay(
                    name: "AncientWarriors",
                    description: "NFT Collection of brave and strong ancient warriors.",
                    externalURL: MetadataViews.ExternalURL(imageUrl),
                    squareImage: media,
                    bannerImage: media,
                    socials: {}
                )
            case Type<MetadataViews.NFTCollectionData>():
                return MetadataViews.NFTCollectionData(
                        storagePath: AncientWarriors.CollectionStoragePath,
                        publicPath: AncientWarriors.CollectionPublicPath,
                        providerPath: /private/exampleNFTCollection,
                        publicCollection: Type<&AncientWarriors.Collection{AncientWarriors.AncientWarriorsCollectionPublic}>(),
                        publicLinkedType: Type<&AncientWarriors.Collection{AncientWarriors.AncientWarriorsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Receiver,MetadataViews.ResolverCollection}>(),
                        providerLinkedType: Type<&AncientWarriors.Collection{AncientWarriors.AncientWarriorsCollectionPublic,NonFungibleToken.CollectionPublic,NonFungibleToken.Provider, MetadataViews.ResolverCollection}>(),
                        createEmptyCollectionFunction: (fun (): @NonFungibleToken.Collection {
                            return <-AncientWarriors.createEmptyCollection()
                        })
                    )
            case Type<MetadataViews.Traits>():
                // exclude mintedTime and foo to show other uses of Traits
                let excludedTraits = ["mintedTime", "civilization"]
                let traitsView = MetadataViews.dictToTraits(dict: self.metadata, excludedNames: excludedTraits)
                // mintedTime is a unix timestamp, we should mark it with a displayType so platforms know how to show it.
                let mintedTimeTrait = MetadataViews.Trait(name: "mintedTime", value: self.metadata["mintedTime"]!, displayType: "Date", rarity: nil)
                traitsView.addTrait(mintedTimeTrait)
                // foo is a trait with its own rarity
                let civilizationTraitRarity = self.getCivilizationRarity(self.metadata["civilization"] as? UInt8)
                let civilizationTrait = MetadataViews.Trait(name: "Civilization", value: self.metadata["civilization"], displayType: nil, rarity: civilizationTraitRarity)
                traitsView.addTrait(civilizationTrait)
                
                return traitsView
          }
          return nil
        }
    }

      /// Defines the methods that are particular to this NFT contract collection
    ///
    pub resource interface AncientWarriorsCollectionPublic {
        pub fun deposit(token: @NonFungibleToken.NFT)
        pub fun getIDs(): [UInt64]
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT
        pub fun borrowAncientWarrior(id: UInt64): &AncientWarriors.NFT? {
            post {
                (result == nil) || (result?.id == id):
                    "Cannot borrow AncientWarrior reference: the ID of the returned reference is incorrect"
            }
        }
    }

    pub resource Collection: AncientWarriorsCollectionPublic, NonFungibleToken.Provider, NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, MetadataViews.ResolverCollection {
        // dictionary of NFT conforming tokens
        // NFT is a resource type with an `UInt64` ID field
        pub var ownedNFTs: @{UInt64: NonFungibleToken.NFT}
        
        init () {
            self.ownedNFTs <- {}
        }
        
        /// Removes an NFT from the collection and moves it to the caller
        ///
        /// @param withdrawID: The ID of the NFT that wants to be withdrawn
        /// @return The NFT resource that has been taken out of the collection
        ///
        pub fun withdraw(withdrawID: UInt64): @NonFungibleToken.NFT{
            let token <- self.ownedNFTs.remove(key: withdrawID) ?? panic("missing NFT")
            emit Withdraw(id: token.id, from: self.owner?.address)
            return <- token
        }

        /// Adds an NFT to the collections dictionary and adds the ID to the id array
        ///
        /// @param token: The NFT resource to be included in the collection
        /// 
        pub fun deposit(token: @NonFungibleToken.NFT) {
            let token <- token as! @AncientWarriors.NFT
            let id = token.id
            let oldToken <- self.ownedNFTs[id] <- token
            emit Deposit(id: id, to: self.owner?.address)
            destroy  oldToken
        }

        /// Helper method for getting the collection IDs
        ///
        /// @return An array containing the IDs of the NFTs in the collection
        ///
        pub fun getIDs(): [UInt64] {
            return self.ownedNFTs.keys
        }

        /// Gets a reference to an NFT in the collection so that 
        /// the caller can read its metadata and call its methods
        ///
        /// @param id: The ID of the wanted NFT
        /// @return A reference to the wanted NFT resource
        ///
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return (&self.ownedNFTs[id] as &NonFungibleToken.NFT?)!
        }

        pub fun borrowAncientWarrior(id:UInt64): &AncientWarriors.NFT? {
            if(self.ownedNFTs[id] != nil) {
                let ref = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
                return ref as! &AncientWarriors.NFT
            }
            return nil
        }

        /// Gets a reference to the NFT only conforming to the `{MetadataViews.Resolver}`
        /// interface so that the caller can retrieve the views that the NFT
        /// is implementing and resolve them
        ///
        /// @param id: The ID of the wanted NFT
        /// @return The resource reference conforming to the Resolver interface
        /// 
        pub fun borrowViewResolver(id: UInt64): &AnyResource{MetadataViews.Resolver} {
            let nft = (&self.ownedNFTs[id] as auth &NonFungibleToken.NFT?)!
            let ancientWarrior = nft as! &AncientWarriors.NFT
            return ancientWarrior as &AnyResource{MetadataViews.Resolver}
        }

        destroy() {
            destroy self.ownedNFTs
        }
    }

    /// Allows anyone to create a new empty collection
    ///
    /// @return The new Collection resource
    ///
    pub fun createEmptyCollection(): @NonFungibleToken.Collection {
        return <- create Collection()
    }

    /// Mints a new NFT with a new ID and deposit it in the
    /// recipients collection using their collection reference
    ///
    /// @param recipient: A capability to the collection where the new NFT will be deposited
    /// @param name: The name for the NFT metadata
    /// @param description: The description for the NFT metadata
    /// @param thumbnail: The thumbnail for the NFT metadata
    /// @param royalties: An array of Royalty structs, see MetadataViews docs 
    ///
    pub fun mintNFT(   
            recipient: &{NonFungibleToken.CollectionPublic},
            name: String,
            description: String,
            thumbnail: String,
            civilization: Civilization
            ){
        let metadata: {String: AnyStruct} = {}
        let currentBlock = getCurrentBlock()
        metadata["mintedTime"] = currentBlock.timestamp
        metadata["minter"] = recipient.owner!.address
        metadata["civilization"] = civilization.rawValue
        
        var newAncientWarrior <- create NFT(
            id: AncientWarriors.totalSupply,
            name: name,
            description: description,
            thumbnail: thumbnail,
            metadata: metadata,
        )

        recipient.deposit(token: <- newAncientWarrior)

        AncientWarriors.totalSupply = AncientWarriors.totalSupply + UInt64(1);
    }

    init(){
        self.totalSupply = 0;

        self.CollectionStoragePath = /storage/ancientWarriorsCollection
        self.CollectionPublicPath = /public/ancientWarriorsCollection

        let collection <- create Collection()
        self.account.save(<-collection, to: self.CollectionStoragePath)

        self.account.link<&AncientWarriors.Collection{NonFungibleToken.CollectionPublic, AncientWarriors.AncientWarriorsCollectionPublic, MetadataViews.ResolverCollection}>(
            self.CollectionPublicPath, 
            target: self.CollectionStoragePath)

        emit ContractInitialized()
    }

 }
 