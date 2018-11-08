<template>
  <div>
    <aside class="menu">
      <ul class="menu-list">
        <li><router-link :to="'/'" :class="{'is-active': routePath=='/'}">HOME</router-link></li>
        <li>
          <div>
            <router-link :to="'/children'" :class="{'is-active': routePath=='/children'}">
              <span class="icon is-small plus-button" @click="openAddChildModal">
                <v-icon name="plus-circle"/>
              </span>
              <span>MY CHILDREN</span>
           </router-link>
          </div>
          <ul>
            <li v-for="c in children" :key="'nav-child-'+c.childId">
              <router-link :to="'/children/' + c.childId" :class="{'is-active': routePath=='/children/' + c.childId}">{{c.child.firstName}}</router-link>
            </li>
          </ul>
        </li>
      </ul>
    </aside>
  </div>
</template>

<script>


export default {
  name: 'my-sidebar',
  data () {
    return {
      addChildModal: {
        opened: false
      },
    }
  },
  computed: {
    children () {
      return this.$store.state.children.children
    },
    routePath () {
      return this.$route.path
    },
  },
  methods: {
    openAddChildModal (event) {
      event.preventDefault()
      event.stopPropagation()
      this.$store.commit('modals/openAddChildModal')
    }
  },
  mounted () {
    
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.sidebar-section {
  margin-bottom: 15px;
}

.sidebar-item {
  padding-top: 5px;
  padding-bottom: 5px;
}

.plus-button {
  float: right;
  position: relative;
  top: 2px;
}

</style>
