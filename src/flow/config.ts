import { config } from "@onflow/fcl";

config({
  "app.detail.title": "Ancient Warriors",
  "app.detail.icon":
    "https://images.fineartamerica.com/images/artworkimages/mediumlarge/1/ancient-warriors-arturas-slapsys.jpg",
  "discovery.wallet": process.env.NEXT_PUBLIC_DISCOVERY_WALLET,
  "accessNode.api": process.env.NEXT_PUBLIC_ACCESS_NODE_API,
  "0xAncientWarriors": process.env.NEXT_PUBLIC_CONTRACT_ANCIENT_WARRIORS,
});
