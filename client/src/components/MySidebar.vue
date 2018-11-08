<template>
  <div>
    <aside class="menu">
      <ul class="menu-list">
        <li><a :class="{'is-active': routePath=='/'}" @click="switchRoute('/')">HOME</a></li>
        <li>
          <div>
            <a :class="{'is-active': routePath=='/children'}" @click="switchRoute('/children')">
              <span class="icon is-small plus-button" @click="openAddChildModal">
                <v-icon name="plus-circle"/>
              </span>
              <span>MY CHILDREN</span>
           </a>
          </div>
          <ul>
            <li v-for="c in children" :key="'nav-child-'+c.childId">
              <a :class="{'is-active': routePath=='/children/' + c.childId}" @click="switchRoute('/children/' + c.childId)">{{c.child.firstName}}</a>
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
    isMobile () {
      return this.$store.state.ui.isMobile
    },
  },
  methods: {
    openAddChildModal (event) {
      event.preventDefault()
      event.stopPropagation()
      this.$store.commit('modals/openAddChildModal')
    },
    switchRoute (route) {
      if(this.isMobile){
        this.$store.commit('ui/setShowSidebar', false)
      }
      if(this.routePath != route){
        this.$router.push(route)
      }
    }
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
