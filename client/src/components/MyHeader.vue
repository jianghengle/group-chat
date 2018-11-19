<template>
  <div>
    <div class="common-header level is-mobile"
      :class="{'mobile-header': isMobile, 'desktop-header': !isMobile}"
      :style="{'left': mainContainerLeft+'px', 'width': mainContainerInnerWidth+'px', 'margin-left': marginLeft+'px'}">
      <div class="level-left">
        <a class="level-item" :class="{'has-text-grey': showSidebar, 'has-text-grey-light': !showSidebar}"
          @click="toggleSidebar">
          <span class="icon">
            <v-icon name="ellipsis-v"/>
          </span>
        </a>
        <div class="has-text-weight-bold level-item" :class="{'is-size-4': !isMobile, 'is-size-5': isMobile}">
          {{title}}
        </div>
      </div>
      <div class="level-right">
        <div class="level-item has-text-grey is-size-7" v-if="webSocket != 'Connected'">
          {{webSocket}}
        </div>
        <a class="level-item" v-if="showSettingButton"
          :class="{'has-text-grey': routeName=='GroupDetail', 'has-text-grey-light':  routeName=='GroupPage'}"
          @click="toggleShowSetting">
          <span class="icon">
            <v-icon name="cog"/>
          </span>
        </a>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'my-header',
  computed: {
    fullName () {
      return this.$store.state.user.fullName
    },
    isMobile () {
      return this.$store.state.ui.isMobile
    },
    mainContainerLeft () {
      return this.$store.state.ui.mainContainerLeft
    },
    marginLeft () {
      var left = (this.mainContainerWidth - this.mainContainerInnerWidth) / 2
      return this.showSidebar ? 0 : left
    },
    mainContainerInnerWidth () {
      return this.$store.state.ui.mainContainerInnerWidth
    },
    mainContainerWidth () {
      return this.$store.state.ui.mainContainerWidth
    },
    showSidebar () {
      return this.$store.state.ui.showSidebar
    },
    webSocket () {
      return this.$store.state.user.webSocket
    },
    routePath () {
      return this.$route.path
    },
    routeName () {
      return this.$route.name
    },
    title () {
      if(this.routeName == 'MyUser')
        return 'User Profile'
      if(this.routeName == 'PublicGroups')
        return 'Public Groups'
      if(this.routeName == 'AddGroup')
        return 'Add Group'
      if(this.routeName == 'GroupPage' || this.routeName == 'GroupDetail'){
        var groupId = this.$route.params.groupId
        var group = this.$store.state.groups.groups[groupId]
        if(group){
          if(group.category == 'conversation' && group.name == '__')
            return 'Yourself Only!'
          return group.name
        }
      }
      return ''
    },
    showSettingButton () {
      return this.routeName == 'GroupPage' || this.routeName == 'GroupDetail'
    }
  },
  methods: {
    toggleSidebar () {
      console.log(this.$route)
      this.$store.commit('ui/toggleSidebar')
    },
    toggleShowSetting () {
      var groupId = this.$route.params.groupId
      if(this.routeName == 'GroupPage'){
        this.$router.push('/group_detail/' + groupId)
      }else{
        this.$router.push('/group/' + groupId)
      } 
    }
  },
}
</script>

<style lang="scss" scoped>

.desktop-header {
  height: 50px;
  padding-left: 10px;
  padding-right: 10px;
}

.mobile-header {
  height: 40px;
  padding-left: 10px;
  padding-right: 10px;
}

.common-header {
  position: fixed;
  top: 0px;
  background-color: white;
  min-width: 300px;
  box-shadow: 0 2px 0 0 #f5f5f5;
  z-index: 10;
}

</style>