<template>
  <div class="content">
    <div>Account: {{accounts[0]}}</div>
    <div>Balance: {{balance}}</div>
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

    <q-list padding separator class="shadow-2 bg-white q-mt-md">
      <q-item-label header class="text-h5">Number of Candidates: <span class="text-weight-bold">{{candidatesLength}}</span></q-item-label>
      <q-item v-for="(candidate, index) in candidates" :key="index" class="q-mb-sm" clickable v-ripple>
        <q-item-section side>
          <q-avatar size="72px">
            <img :src="`https://avatars.dicebear.com/api/adventurer/${index}.svg`">
          </q-avatar>
        </q-item-section>

        <q-item-section>
          <q-item-label class="text-subtitle1">Candidate: #<span class="text-weight-bold">{{index + 1}}</span></q-item-label>
          <q-item-label class="text-subtitle1">Name: <span class="text-weight-bold">{{candidate[0]}}</span></q-item-label>
          <q-item-label class="text-subtitle2">Votes: <span class="text-weight-bold">{{candidate[1]}}</span></q-item-label>
        </q-item-section>

        <q-item-section side>
          <q-btn @click="addVote(index)" icon="thumb_up_alt" color="secondary" push label="Vote" />
        </q-item-section>
      </q-item>
    </q-list>
  </div>
</template>

<script setup>
  import contractAbi from '../contract-abis/ballot.json'
  import { ethers, utils } from "ethers";
  import { onMounted, ref, reactive } from "vue";

  const candidate = reactive({
    name: 'Pacman',
    voteCount: 0
  });
  
  let provider = null;
  let contract = null;
  const candidatesLength = ref(0);
  const candidates = ref([]);
  const accounts = ref([]);
  const balance = ref(0);

  onMounted(() => {
  });

  async function addVote (candidateIndex) {
    let signer = provider.getSigner()
    let contractWithSigner = contract.connect(signer)
    let transaction = await contractWithSigner.vote(candidateIndex)

    await transaction.wait()
    getCandidates()
  }

  async function connectToMetamask () {
    provider = new ethers.providers.Web3Provider(window.ethereum)
    const response = await provider.send('eth_requestAccounts', [])
    accounts.value = response
    getBalance()
    createContractInstance()
  }

  async function getBalance () {
    const rawBalance = await provider.getBalance(accounts.value[0])
    balance.value = utils.formatEther(rawBalance)
  }

  function createContractInstance () {
    contract = new ethers.Contract('0x7BdF3CB51Da0568603cA29493861C0015dF1d121', contractAbi)
    contract = contract.connect(provider)
    getCandidates()
  }

  async function getCandidates () {
    candidates.value = []
    const response = await contract.getCandidatesLength()
    candidatesLength.value = response

    for (let index = 0; index < candidatesLength.value; index++) {
      const element = await contract.candidates(index)
      candidates.value.push(element)
    }
  }

  function disconnectToMetamask () {
    accounts.value = []
    balance.value = 0
    provider = null
    contract = null
    candidates.value = []
    candidatesLength.value = 0
  }
</script>

<style lang="sass" scoped>
.content
  max-width: 550px
  margin: auto
</style>

