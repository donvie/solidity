<template>
  <q-page padding>
    <div class="q-gutter-sm q-mb-md">
      <q-btn label="Voting Application" @click="isHideCandidate = !isHideCandidate" />
      <q-btn label="Token Swap" @click="isHideTokenSwap = !isHideTokenSwap" />
      <q-btn label="Mint" @click="isHideMintPage = !isHideMintPage" />
    </div>
    <CandidatesList v-if="isHideCandidate" />
    <TokenSwap v-if="isHideTokenSwap" />
    <MintPage v-if="isHideMintPage" />
  </q-page>
</template>

<script setup>
import { ref } from "vue";
import TokenSwap from 'components/TokenSwap.vue'
import CandidatesList from 'components/CandidatesList.vue'
import MintPage from 'components/MintPage.vue'

const isHideCandidate = ref(false)
const isHideTokenSwap = ref(false)
const isHideMintPage = ref(false)
</script>
