import Vue from 'vue'
import Router from 'vue-router'
import MyHome from '@/components/MyHome'
import ChildrenSection from '@/components/children/ChildrenSection'
import ChildPage from '@/components/children/ChildPage'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'MyHome',
      component: MyHome
    },
    {
      path: '/children',
      name: 'ChildrenSection',
      component: ChildrenSection
    },
    {
      path: '/children/:childId',
      name: 'ChildPage',
      component: ChildPage
    }
  ]
})
