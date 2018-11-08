<template>
  <div>
    <div class="is-size-4 has-text-weight-bold section-header">
      {{child.firstName + ' ' + child.lastName}}
    </div>
    <div class="tabs">
      <ul>
        <li v-for="tab in tabs" :class="{'is-active': currentTab==tab}"><a @click="currentTab = tab">{{tab}}</a></li>
      </ul>
    </div>
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
    }
  },
  computed: {
    childId () {
      return this.$route.params.childId
    }
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
.section-header {
  margin-bottom: 10px;
}

.child-box {
  padding: 15px;
  cursor: pointer;
}
</style>
