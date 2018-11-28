<template>
  <chats v-if="group" :navigation="navigation" />
</template>

<script>
import store from '../store'
import Chats from './Chats'

export default {
  components: {
    Chats
  },
  props: {
    navigation: {
      type: Object
    }
  },
  computed: {
    groupId () {
      return this.navigation.state.params.groupId
    },
    group () {
      return store.state.groups.groups[this.groupId]
    }
  },
}
</script>

 
<style>

</style>
