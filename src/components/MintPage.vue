<template>
  <div class="content">
    <div>Account: {{accounts[0]}}</div>

    <q-btn
      v-if="accounts.length === 0"
      class="q-mb-md"
      color="secondary"
      @click="connectToMetamask">
        <span class="q-mr-xs">Connect</span>
        <q-avatar size="27px">
          <img src="https://uxwing.com/wp-content/themes/uxwing/download/10-brands-and-social-media/metamask.png">
        </q-avatar>
    </q-btn>

    <q-btn
      v-else
      class="q-mb-md"
      color="secondary"
      @click="disconnectToMetamask">
        <span class="q-mr-xs">Disconnect</span>
        <q-avatar size="27px">
          <img src="https://uxwing.com/wp-content/themes/uxwing/download/10-brands-and-social-media/metamask.png">
        </q-avatar>
    </q-btn>
    <br>
    <q-btn @click="mintNft" label="Mint NFT" class="q-mb-md" />
    <div  class="row"> 
    <div v-for="(nft, index) in nfts" :key="index" class="col-4">
        <div class="text-h6">#{{ index + 1 }}</div>
        <img :src="nft.image" height="150"/>
        <div v-for="(attr, index2) in nft.attributes" :key="index2" class="nft-attr">
            <strong>{{ attr.trait_type }}</strong> - {{ attr.value }}
        </div>
      </div>
    </div>

    
    <!-- <pre>{{nfts}}</pre> -->
  </div>
</template>

<script setup>
  import erc721Abi from "../contract-abis/erc721.json"
  import { ethers, utils } from "ethers";
  import { ref, reactive } from "vue";

  let provider = null;
  let nftContract = null;
  let accounts = ref([]);
  let nfts = ref([]);

  async function connectToMetamask () {
    provider = new ethers.providers.Web3Provider(window.ethereum)
    const response = await provider.send('eth_requestAccounts', [])
    accounts.value = response

    createContractInstances()
  }

  function createContractInstances () {
    nftContract = new ethers.Contract('0x8fd7d547CAa342D5aA239c1577Ece3ba34C007C0', erc721Abi)
    nftContract = nftContract.connect(provider)
    getOwnedNfts()
  }

  function disconnectToMetamask () {
    accounts.value = []
    provider = null
  }

  async function mintNft () {
    let signer = provider.getSigner()
    let nftContractWithSigner = nftContract.connect(signer);
    var transaction = await nftContractWithSigner.mint()
    await transaction.wait()
    alert('Minted NFT!')
    getOwnedNfts()
  }

  async function getOwnedNfts () {
    var ownedTokensLength = await nftContract.ownerTokensLength(accounts.value[0])

    console.log('tokenUri', ownedTokensLength)
    nfts.value = []

    for(var i = 0; i < ownedTokensLength; i++) {
        var tokenId = await nftContract.ownerTokens(accounts.value[0], i)
        var tokenUri = await nftContract.tokenURI(tokenId)
        var _response = await fetch(tokenUri)
        var tokenMetadata = await _response.json()
        nfts.value.push(tokenMetadata)
    }

  }
</script>

<style lang="sass" scoped>
.content
  max-width: 550px
  margin: auto


.nft-card
    background-color: #eee
    border-radius: 5px
    box-shadow: #9a9a9a 2px 2px 3px
    padding: 15px
    margin-bottom: 15px

.nft
    border: 1px solid black
    border-radius: 5px
    
</style>

