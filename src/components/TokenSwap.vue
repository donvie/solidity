<template>
  <div class="content">
    <div>Account: {{accounts[0]}}</div>
    <div>TokenA Balance: {{tokenABalance}}</div>
    <div>TokenB Balance: {{tokenBBalance}}</div>

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

    <!-- <div>{{swapForm}}</div> -->
    <q-select label="Swap Type" v-model="swapForm.swapType" :options="swapTypeOPtions" />
    <q-input label="Amount from" type="number" v-model.number="swapForm.amountFrom" />
    <q-input label="Amount to" type="number" v-model.number="swapForm.amountTo" />
    <br>
    <q-btn color="secondary" label="Create Swap" @click="createSwapOffer" />

    <q-list bordered separator class="q-mt-md" v-if="swapOffers.length !== 0">
      <q-item clickable v-ripple v-for="(swapOffer, index) in swapOffers" :key="index">
        <q-item-section v-if="swapOffer.swapType === 0">
          <q-item-label>Created by: {{ swapOffer.creator }} Token A</q-item-label>
          <q-item-label>From: {{ swapOffer.fromTokens }} Token A</q-item-label>
          <q-item-label>To: {{ swapOffer.toTokens}} Token B</q-item-label>
        </q-item-section>
        <q-item-section v-else-if="swapOffer.swapType === 1">
          <q-item-label>From: {{ swapOffer.fromTokens }} Token B</q-item-label>
          <q-item-label>To: {{ swapOffer.toTokens}} Token A</q-item-label>
        </q-item-section>
        <q-item-section side>
          <q-btn v-if="!swapOffer.isSwapped" label="Swap" @click="fulfillSwap(swapOffer)" />
        </q-item-section>
      </q-item>
    </q-list>
  </div>
</template>

<script setup>
  import tokenAAbi from "../contract-abis/tokenA.json"
  import tokenBAbi from "../contract-abis/tokenB.json"
  import tokenSwapAbi from "../contract-abis/token-swap.json"
  import { ethers, utils } from "ethers";
  import { ref, reactive } from "vue";

  let provider = null;
  let tokenA = null;
  let tokenB = null;
  let tokenSwap = null;
  
  let tokenABalance = ref(0);
  let tokenBBalance = ref(0);

  let accounts = ref([]);

  const swapOffers = ref([]);
  let swapsLength = ref(0);

  const message = ref('');

 const swapType = ref('');
 
 const swapTypeOPtions = ref([
    'Token A for Token B',
    'Token B for Token A',
 ]);
  const swapForm = ref({
    swapType: null,
    amountFrom: null,
    amountTo: null
  })

  async function connectToMetamask () {
    provider = new ethers.providers.Web3Provider(window.ethereum)
    const response = await provider.send('eth_requestAccounts', [])
    accounts.value = response

    createContractInstances()
    getTokenBalances()
  }

  function createContractInstances () {
    tokenA = new ethers.Contract('0x2Cd95Bca3ae285e6df346583C04a6fF8bc16bE3F', tokenAAbi)
    tokenA = tokenA.connect(provider)
    
    tokenB = new ethers.Contract('0xA014D6F7f55C23F4852bC7B16347884E7C4E0D8b', tokenBAbi)
    tokenB = tokenB.connect(provider)

    tokenSwap = new ethers.Contract('0xBcD0924DdC2E3E7AA042c94e3c387ff8A65C7967', tokenSwapAbi)
    tokenSwap = tokenSwap.connect(provider)

    getSwapsList()
  }

  async function getTokenBalances () {
    let _tokenABalance = await tokenA.balanceOf(accounts.value[0]);
    let tokenADecimals = await tokenA.decimals();
    tokenABalance.value = utils.formatUnits(_tokenABalance, tokenADecimals)

    let _tokenBBalance = await tokenB.balanceOf(accounts.value[0]);
    let tokenBDecimals = await tokenB.decimals();
    tokenBBalance.value = utils.formatUnits(_tokenBBalance, tokenBDecimals)
  }

  function disconnectToMetamask () {
    accounts.value = []
    provider = null
  }

  async function getSwapsList () {
    var swapsLength = await tokenSwap.getSwapsLength()
    swapOffers.value = []

    for (var i = 0; i < swapsLength; i++) {
      var _swap = await tokenSwap.swaps(i)
      var swap = {
        swapType: _swap.swapType,
        creator: _swap.creator,
        swappedBy: _swap.swappedBy,
        amountFrom: _swap.amountFrom,
        amountTo: _swap.amountTo,
        isSwapped: _swap.isSwapped,
      }

      swap.swapIndex = i
      swap.fromTokens = utils.formatUnits(swap.amountFrom, 18)
      swap.toTokens = utils.formatUnits(swap.amountTo, 18)

      swapOffers.value.push(swap)
    }
  }

  async function createSwapOffer () {
      let signer = provider.getSigner();
      let contractWithSigner = tokenSwap.connect(signer);


      var tokenFrom;
      if (swapForm.value.swapType === 'Token A for Token B') {
        tokenFrom = tokenA
      } else if (swapForm.value.swapType === 'Token B for Token A') {
        tokenFrom = tokenB
      }
  
      let tokenFromWithSigner = tokenFrom.connect(signer)

      let amountFrom = utils.parseUnits(String(swapForm.value.amountFrom), 18)
      let amountTo = utils.parseUnits(String(swapForm.value.amountTo), 18)

      const approveTx = await tokenFromWithSigner.approve(tokenSwap.address, amountFrom)
      await approveTx.wait()

      let transaction = await contractWithSigner.createSwap(
        swapForm.value.swapType === 'Token A for Token B' ? 0 : 1,
        amountFrom,
        amountTo
      )

      await transaction.wait()
      getTokenBalances()
  }
  
   async function fulfillSwap(swapOffer) {
    console.log('swapOffer', swapOffer)
    var signer = provider.getSigner()
    var tokenSwapWithSigner = tokenSwap.connect(signer)

    var tokenTo
    if (swapOffer.swapType === 0) {
      tokenTo = tokenB
    } else if (swapOffer.swapType === 1) {
      tokenTo = tokenA
    }

    var tokenToWithSigner = tokenTo.connect(signer)
    var approveTx = await tokenToWithSigner.approve(tokenSwap.address, swapOffer.amountTo)
    await approveTx.wait()

    var transaction = await tokenSwapWithSigner.swap(swapOffer.swapIndex)
    await transaction.wait()

    getSwapsList()
    getTokenBalances()
  }

</script>

<style lang="sass" scoped>
.content
  max-width: 550px
  margin: auto
</style>

