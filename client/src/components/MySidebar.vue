<template>
  <div>
    <aside class="menu">
      <ul class="menu-list">
        <li><a :class="{'is-active': routePath=='/'}" @click="switchRoute('/')">Home</a></li>
        <li>
          <div>
            <a :class="{'is-active': routePath=='/children'}" @click="switchRoute('/children')">
              <span class="icon is-small plus-button" @click="openAddChildModal">
                <v-icon name="plus-circle"/>
              </span>
              <span>My Children</span>
           </a>
          </div>
          <ul>
            <li v-for="c in children" :key="'nav-child-'+c.childId">
              <a :class="{'is-active': routePath=='/children/' + c.childId}" @click="switchRoute('/children/' + c.childId)">{{c.child.firstName}}</a>
            </li>
          </ul>
        </li>
        <li>
          <div>
            <a :class="{'is-active': routePath=='/groups'}" @click="switchRoute('/groups')">
              <span class="icon is-small plus-button" @click="openAddGroupModal">
                <v-icon name="plus-circle"/>
              </span>
              <span>My Activities</span>
           </a>
          </div>
          <ul>
            <li v-for="g in groups" :key="'nav-group-'+g.id">
              <a :class="{'is-active': routePath=='/groups/' + g.id}" @click="switchRoute('/groups/' + g.id)">{{g.name}}</a>
            </li>
          </ul>
        </li>
        <li><a :class="{'is-active': routePath=='/public_groups'}" @click="switchRoute('/public_groups')">Search Activities</a></li>
        <li><a>Direct Messages</a></li>
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
      return Object.values(this.$store.state.children.children).filter(function(c){
        return c
      })
    },
    routePath () {
      return this.$route.path
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    groups () {
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return g
      })
    }
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
    },
    openAddGroupModal (event) {
      event.preventDefault()
      event.stopPropagation()
      this.$store.commit('modals/openAddGroupModal')
    },
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
