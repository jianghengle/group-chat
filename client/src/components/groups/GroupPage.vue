<template>
  <div v-if="group">
    <chats></chats>
  </div>
</template>

<script>
import Chats from './Chats'

export default {
  name: 'group-page',
  components: {
    Chats
  },
  computed: {
    groupId () {
      return this.$route.params.groupId
    },
    group () {
      return this.$store.state.groups.groups[this.groupId]
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>


</style>
