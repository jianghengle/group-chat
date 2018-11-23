<template>
  <nb-container :style="{backgroundColor: '#fff'}">
    <nb-header>
      <nb-left>
        <nb-button
          transparent
          :onPress="() => this.props.navigation.navigate('DrawerOpen')"
        >
          <nb-icon name="arrow-back" />
        </nb-button>
      </nb-left>
      <nb-body>
        <nb-title :style="{width: 300}">Public Groups</nb-title>
      </nb-body>
      <nb-right />
    </nb-header>

    <nb-content padder>
      <nb-text>Public groups</nb-text>
    </nb-content>

  </nb-container>
</template>

<script>
import { Toast } from "native-base";
import store from '../store'
import axios from 'axios'

export default {
  props: {
    navigation: {
      type: Object
    }
  },
  data: function() {
    return {
      waiting: false
    }
  },
  methods: {
    
  },
  created () {
    
  }
}
</script>

 
<style>

</style>
