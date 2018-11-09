<template>
  <div class="home-container">
    <children-section/>
    <hr class="hr">
    <groups-section/>
    <hr class="hr">
  </div>
</template>

<script>
import ChildrenSection from './children/ChildrenSection'
import GroupsSection from './groups/GroupsSection'

export default {
  name: 'my-home',
  components: {
    ChildrenSection,
    GroupsSection
  },
  data () {
    return {
      msg: 'Hello world!'
    }
  },
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

</style>
