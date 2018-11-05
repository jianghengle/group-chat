import Vue from 'vue'
import Router from 'vue-router'
import MyMain from '@/components/MyMain'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MyMain',
      component: MyMain
    }
  ]
})
