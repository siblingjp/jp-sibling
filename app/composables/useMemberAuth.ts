export function useMemberAuth() {
  const store = useMemberStore()
  return {
    member: storeToRefs(store).member,
    isMemberAuthenticated: storeToRefs(store).isMemberAuthenticated,
    login: store.login,
    logout: store.logout,
    fetchMe: store.fetchMe,
  }
}
