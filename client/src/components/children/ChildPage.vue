<template>
  <div>
    <div v-if="isMobile" class="common-header mobile-header" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="dropdown is-right mobile-dropdown" :class="{'is-active': dropdownOpen}" @click="dropdownOpen = !dropdownOpen">
        <div class="dropdown-trigger">
          <button class="button" aria-haspopup="true" aria-controls="dropdown-menu">
            <span>{{currentTab}}</span>
            <span class="icon is-small">
              <v-icon name="angle-down"></v-icon>
            </span>
          </button>
        </div>
        <div class="dropdown-menu" id="dropdown-menu" role="menu">
          <div class="dropdown-content">
            <a v-for="tab in tabs" class="dropdown-item" :class="{'is-active': currentTab==tab}" @click="currentTab = tab">
              {{tab}}
            </a>
          </div>
        </div>
      </div>
      <div class="is-size-5 has-text-weight-bold">
        {{child.firstName + ' ' + child.lastName}}
      </div>
    </div>
    <div v-else class="common-header desktop-header" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="is-size-4 has-text-weight-bold">
        {{child.firstName + ' ' + child.lastName}}
      </div>
      <div class="tabs">
        <ul>
          <li v-for="tab in tabs" :class="{'is-active': currentTab==tab}"><a @click="currentTab = tab">{{tab}}</a></li>
        </ul>
      </div>
    </div>
    <div class="common-body" :class="{'desktop-body': !isMobile, 'mobile-body': isMobile}" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="has-text-centered" v-if="waiting">
        <v-icon name="spinner" class="icon fa-spin"></v-icon>
      </div>
      <div v-else>
        <div v-if="error" class="notification is-danger login-text">
          <button class="delete" @click="error=''"></button>
          {{error}}
        </div>
        <div>
          <div v-if="currentTab == 'Moments'">
            Moments
          </div>
          <div v-if="currentTab == 'Schedule'">
            Schedule: enrolled classes, schedule and Calender
          </div>
          <div v-if="currentTab == 'Guardians'">
            <child-guardians :child="child" @guardian-removed="requestChild"></child-guardians>
          </div>
          <div v-if="currentTab == 'Profile'">
            <child-profile :child="child" @child-profile-updated="requestChild"></child-profile>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import ChildProfile from './ChildProfile'
import ChildGuardians from './ChildGuardians'

export default {
  name: 'child-page',
  components: {
    ChildProfile,
    ChildGuardians
  },
  data () {
    return {
      waiting: false,
      error: '',
      child: {},
      tabs: ['Moments', 'Schedule', 'Guardians', 'Profile'],
      currentTab: 'Moments',
      dropdownOpen: false
    }
  },
  computed: {
    childId () {
      return this.$route.params.childId
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerWidth
    },
  },
  watch: {
    childId: function (val) {
      this.requestChild()
    }
  },
  methods: {
    requestChild () {
      this.waiting = true
      this.$http.get(xHTTPx + '/guardian_get_child/' + this.childId).then(response => {
        var resp = response.body
        var child = resp[0]
        var userMap = {}
        resp[1].forEach(function(u){
          userMap[u.id] = u
        })
        child.guardians = resp[2].map(function(g){
          g.parent = userMap[g.parentId]
          return g
        })
        this.child = child
        this.waiting= false
      }, response => {
        this.error = 'Failed to get child!'
        this.waiting= false
      })
    }
  },
  mounted () {
    this.$nextTick(function(){
      this.requestChild()
    })
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>

.desktop-header {
  height: 110px;
  padding-top: 15px;
  padding-left: 20px;
  padding-right: 20px;
}

.mobile-header {
  height: 50px;
  padding-top: 10px;
  padding-left: 10px;
  padding-right: 10px;
}

.common-header {
  position: fixed;
  top: 52px;
  background-color: white;
  z-index: 100;
  min-width: 300px;
}

.desktop-body {
  top: 152px;
  padding-top: 15px;
  padding-left: 20px;
  padding-right: 20px;
  padding-bottom: 10px;
  min-width: 300px;
}

.mobile-body {
  top: 100px;
  padding-top: 10px;
  padding-left: 10px;
  padding-right: 10px;
  padding-bottom: 10px;
}

.common-body {
  position: fixed;
  bottom: 0px;
  overflow: auto;
  min-width: 300px;
}

.mobile-dropdown {
  float: right;
  position: relative;
  top: -3px;
}

</style>
