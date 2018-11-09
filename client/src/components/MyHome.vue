<template>
  <div class="home-container">
    <children-section/>
    <hr class="hr">
    <groups-section/>
    <hr class="hr">
    <public-groups-section/>
  </div>
</template>

<script>
import ChildrenSection from './children/ChildrenSection'
import GroupsSection from './groups/GroupsSection'
import PublicGroupsSection from './groups/PublicGroupsSection'

export default {
  name: 'my-home',
  components: {
    ChildrenSection,
    GroupsSection,
    PublicGroupsSection
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
