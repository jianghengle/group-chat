import Vue from 'vue'
import Router from 'vue-router'
import MyUser from '@/components/MyUser'
import AddGroup from '@/components/AddGroup'
import GroupPage from '@/components/groups/GroupPage'
import GroupDetail from '@/components/groups/GroupDetail'
import PublicGroups from '@/components/groups/PublicGroups'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'PublicGroups',
      component: PublicGroups
    },
    {
      path: '/user',
      name: 'MyUser',
      component: MyUser
    },
    {
      path: '/add_group',
      name: 'AddGroup',
      component: AddGroup
    },
    {
      path: '/group/:groupId',
      name: 'GroupPage',
      component: GroupPage
    },
    {
      path: '/group_detail/:groupId',
      name: 'GroupDetail',
      component: GroupDetail
    }
  ]
})
