// Code begins
// Import libraries and canisters

import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import Candid "mo:base/Candid";

import ICP "ic:canisters/cycles";
import Identity "ic:canisters/identity";

// Defining NFT type

type NFT = {
  owner: Principal;
  name: Text;
  description: Text;
  category: Text;
  image: [Nat8];
  price: Nat;
};

// Define canister

public actor class Marketplace {

  // Initialization

  var nfts : [NFT] = [];
  var listings : [NFT] = [];
  var users : [Principal] = [];

  // Add new NFT

  public shared ({owner, name, description, category, image, price} : NFT) : async () {
    assert !Array.contains(users, owner);
    Array.push(users, owner);
    let new_nft = {owner, name, description, category, image, price};
    Array.push(nfts, new_nft);
  }

  // List NFT for sale

  public shared ({owner, name, description, category, image, price} : NFT) : async () {
    let nft = {owner, name, description, category, image, price};
    assert Array.contains(nfts, nft);
    Array.push(listings, nft);
  }

  // Cancel listing

  public shared ({owner, name, description, category, image, price} : NFT) : async () {
    let nft = {owner, name, description, category, image, price};
    assert Array.contains(listings, nft);
    Array.remove(listings, nft);
  }

  // Purchase NFT

  public shared ({buyer, owner, name, description, category, image, price} : NFT) : async () {
    let nft = {owner, name, description, category, image, price};
    assert Array.contains(listings, nft);
    assert ICP.transfer(buyer, owner, price);
    Array.remove(listings, nft);
    Array.push(nfts, {owner: buyer, name, description, category, image, price});
  }

  // Get NFTs owned by user

  public query owned_by(user : Principal) : async [NFT] {
    let user_nfts = Array.filter(nfts, (nft) => {
      nft.owner == user;
    });
    return user_nfts;
  }

  // Get NFTs currently listed

  public query for_sale() : async [NFT] {
    return listings;
  }

  // Get NFTs

  public query all_nfts() : async [NFT] {
    return nfts;
  }
}
