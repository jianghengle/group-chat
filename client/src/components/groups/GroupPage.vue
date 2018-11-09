<template>
  <div v-if="group">
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
        {{group.name}}
      </div>
    </div>
    <div v-else class="common-header desktop-header" :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="is-size-4 has-text-weight-bold">
        {{group.name}}
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
          <div v-if="currentTab == 'Chats'">
            Chats
          </div>
          <div v-if="currentTab == 'Schedule'">
            Schedule: enrolled classes, schedule and Calender
          </div>
          <div v-if="currentTab == 'Members'">
            <group-members v-if="group" :group="group"></group-members>
          </div>
          <div v-if="currentTab == 'Profile'">
            <group-profile v-if="group" :group="group"></group-profile>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import GroupProfile from './GroupProfile'
import GroupMembers from './GroupMembers'

export default {
  name: 'group-page',
  components: {
    GroupProfile,
    GroupMembers
  },
  data () {
    return {
      waiting: false,
      error: '',
      tabs: ['Chats', 'Schedule', 'Members', 'Profile'],
      currentTab: 'Chats',
      dropdownOpen: false
    }
  },
  computed: {
    groupId () {
      return this.$route.params.groupId
    },
    group () {
      return this.$store.state.groups.groups[this.groupId]
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
  },
  methods: {
    requestChild () {
      
    }
  },
  mounted () {
    console.log(this.group)
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
