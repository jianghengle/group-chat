<template>
  <div class="home-container">
    <children-section/>
    <hr class="hr">
  </div>
</template>

<script>
import ChildrenSection from './children/ChildrenSection'

export default {
  name: 'my-home',
  components: {
    ChildrenSection
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
