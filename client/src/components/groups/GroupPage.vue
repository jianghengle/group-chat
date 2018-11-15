<template>
  <div v-if="group">
    <div class="common-header level is-mobile"
      :class="{'mobile-header': isMobile, 'desktop-header': !isMobile}"
      :style="{'left': mainContainerLeft+'px', 'width': mainContainerWidth+'px'}">
      <div class="level-left">
        <a class="level-item" :class="{'has-text-grey': showSidebar, 'has-text-grey-light': !showSidebar}"
          @click="toggleSidebar">
          <span class="icon">
            <v-icon name="ellipsis-v"/>
          </span>
        </a>
        <div class="has-text-weight-bold level-item clickable"
          :class="{'is-size-4': !isMobile, 'is-size-5': isMobile}"
          @click="showGroupDetail=false">
          {{group.name}}
        </div>
      </div>
      <div class="level-right">
        <div class="level-item has-text-grey is-size-7" v-if="webSocket != 'Connected'">
          {{webSocket}}
        </div>
        <a class="level-item" :class="{'has-text-grey': showGroupDetail, 'has-text-grey-light': !showGroupDetail}"
          @click="showGroupDetail=!showGroupDetail">
          <span class="icon">
            <v-icon name="cog"/>
          </span>
        </a>
      </div>
    </div>

    <div>
      <div v-if="showGroupDetail">
        <group-detail></group-detail>
      </div>
      <div v-else>
        <chats></chats>
      </div>
    </div>
  </div>
</template>

<script>
import GroupDetail from './GroupDetail'
import Chats from './Chats'

export default {
  name: 'group-page',
  components: {
    GroupDetail,
    Chats
  },
  data () {
    return {
      waiting: false,
      error: '',
      showGroupDetail: false,
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
    showSidebar () {
      return this.$store.state.ui.showSidebar
    },
    webSocket () {
      return this.$store.state.user.webSocket
    }
  },
  methods: {
    toggleSidebar () {
      this.$store.commit('ui/toggleSidebar')
    },
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>


</style>
