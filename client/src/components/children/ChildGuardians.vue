<template>
  <div>

    <div class="has-text-centered" v-if="waiting">
      <v-icon name="spinner" class="icon fa-spin"></v-icon>
    </div>
    
    <div v-if="error" class="notification is-danger">
      <button class="delete" @click="error=''"></button>
      {{error}}
    </div>
        
    <div class="columns is-multiline">
      <div v-for="g in child.guardians" class="column is-half">
        <div class="box">
          <a v-if="myself && myself.master && g.parentId != userId" class="delete delete-button" @click="removeGuardian(g)"></a>
          <article class="media">
            <div class="media-left">
              <figure class="image is-64x64">
                <img src="https://bulma.io/images/placeholders/128x128.png" alt="Image">
              </figure>
            </div>
            <div class="media-content">
              <div class="content">
                <p>
                  <strong>{{g.parent.firstName + ' ' + g.parent.lastName}}</strong>
                  <small v-if="g.parentId == userId">(Me)</small>
                  <br />
                  <small>{{g.parent.email}}</small><br />
                  <small>{{g.relation}}</small>
                </p>
              </div>
            </div>
          </article>
        </div>
      </div>
    </div>
    <div>
      <a v-if="myself.master" class="button is-link">Invite More Guardian</a>
    </div>
  </div>
</template>

<script>

export default {
  name: 'child-guardians',
  props: ['child'],
  data () {
    return {
      waiting: false,
      error: '',
    }
  },
  computed: {
    userId () {
      return this.$store.state.user.userId
    },
    childId () {
      return this.$route.params.childId
    },
    myself () {
      for(var i=0;i<this.child.guardians.length;i++){
        var guardian = this.child.guardians[i]
        if(guardian.parentId == this.userId)
          return guardian
      }
      return null
    }
  },
  methods: {
    removeGuardian (guardian) {
      this.$store.commit('modals/openConfirmModal', {
        title: 'Remove Guardian',
        message: 'Are you sure to remove this guardian: ' + guardian.parent.firstName + ' ' + guardian.parent.lastName,
        button: 'Yes, I am sure!',
        callback: {
          method: this.removeGuardianConfirmed,
          context: this,
          args: [guardian]
        }
      })
    },
    removeGuardianConfirmed (guardian) {
      this.waiting = true
      var message = {masterGuardianId: this.myself.id}
      this.$http.post(xHTTPx + '/guardian_remove_guardian/' + guardian.id, message).then(response => {
        this.$emit('guardian-removed')
        this.waiting = false
      }, response => {
        this.error = 'Failed to remove guardian!'
        this.waiting = false
      })
    }
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

.delete-button {
  float: right;
}
</style>
