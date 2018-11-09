import Vue from 'vue'
import Router from 'vue-router'
import MyHome from '@/components/MyHome'
import ChildrenSection from '@/components/children/ChildrenSection'
import ChildPage from '@/components/children/ChildPage'
import GroupsSection from '@/components/groups/GroupsSection'
import GroupPage from '@/components/groups/GroupPage'
import PublicGroupsSection from '@/components/groups/PublicGroupsSection'

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
    },
    {
      path: '/groups',
      name: 'GroupsSection',
      component: GroupsSection
    },
    {
      path: '/groups/:groupId',
      name: 'GroupPage',
      component: GroupPage
    },
    {
      path: '/public_groups',
      name: 'PublicGroupsSection',
      component: PublicGroupsSection
    }
  ]
})
