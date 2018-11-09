<template>
  <div>
    <div class="is-size-4 has-text-weight-bold section-header">
      My Activities
      <a class="button is-text" @click="openAddGroupModal">
        <span class="icon is-small">
          <v-icon name="plus-circle"/>
        </span>
      </a>
    </div>
    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    <div v-else>
      <div v-if="error" class="notification is-danger login-text">
        <button class="delete" @click="error=''"></button>
        {{error}}
      </div>
      <div v-if="!groups.length">You have not been involved by any activity yet.</div>
      <div v-else>
        <div v-if="splitedGroups[0].length" class="splited-group-title">Your provided activities:</div>
        <div class="columns is-multiline">
          <div v-for="g in splitedGroups[0]" class="column is-half">
            <div class="box clickable" @click="viewGroup(g.id)">
              <article class="media">
                <div class="media-content">
                  <div class="content">
                    <p>
                      <strong>{{g.name}}</strong><br/>
                      <small>{{g.category}} by {{g.owner.firstName + ' ' + g.owner.lastName}}</small><br/>
                      <small>{{g.description}}</small><br/>
                      <small>{{g.access}} access | {{g.enroll}} enroll</small>
                    </p>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </div>

        <div v-if="splitedGroups[1].length" class="splited-group-title">Your enrolled activities:</div>
        <div class="columns is-multiline">
          <div v-for="g in splitedGroups[1]" class="column is-half">
            <div class="box clickable" @click="viewGroup(g.id)">
              <article class="media">
                <div class="media-content">
                  <div class="content">
                    <p>
                      <strong>{{g.name}}</strong><br/>
                      <small>{{g.category}} by {{g.owner.firstName + ' ' + g.owner.lastName}}</small><br/>
                      <small>{{g.description}}</small><br/>
                      <small>
                        Enrolled: 
                        <span v-for="(m, i) in g.involved">
                          <span v-if="i!=0">,&nbsp;</span>{{m.user.firstName}}
                        </span>
                      </small>
                    </p>
                  </div>
                </div>
              </article>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'groups-section',
  data () {
    return {
      waiting: false,
      error: ''
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    groups () {
      return Object.values(this.$store.state.groups.groups).filter(function(g){
        return g
      })
    },
    splitedGroups () {
      var provided = []
      var enrolled = []
      for(var i=0;i<this.groups.length;i++){
        var g = this.groups[i]
        if(g.ownerId == this.userId){
          provided.push(g)
        }else{
          var isAdmin = false
          for(var j=0;j<g.involved.length;j++){
            var m = g.involved[j]
            if(m.userId == this.userId && m.role != 'member'){
              isAdmin = true
            }
          }
          if(isAdmin){
            provided.push(g)
          }else{
            enrolled.push(g)
          }
        }
      }
      return [provided, enrolled]
    }
  },
  methods: {
    viewGroup (groupId) {
      this.$router.push('/groups/' + groupId)
    },
    openAddGroupModal () {
      this.$store.commit('modals/openAddGroupModal')  
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style lang="scss" scoped>
.section-header {
  margin-bottom: 10px;
}

.splited-group-title {
  margin-bottom: 10px;
}
</style>
