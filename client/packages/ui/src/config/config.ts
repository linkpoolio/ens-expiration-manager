const getEnv = (app, local) => {
  const key = `GLOBAL_${app}`
  return window[key] ? window[key] : local
}

export const env = {
  ensExpirationManagerContractAddress: () =>
    getEnv(
      `UI_ENS_EXPIRATION_MANAGER_CONTRACT_ADDRESS`,
      // @ts-ignore:next-line
      typeof envEnsExpirationManagerContractAddress == 'string'
        ? // @ts-ignore:next-line
          envEnsExpirationManagerContractAddress
        : undefined // eslint-disable-line no-undef
    ),
  ensENSBaseRegistrarContractAddress: () =>
    getEnv(
      `UI_ENS_BASE_REGISTRAR_CONTRACT_ADDRESS`,
      // @ts-ignore:next-line
      typeof envEnsENSBaseRegistrarContractAddress == 'string'
        ? // @ts-ignore:next-line
          envEnsENSBaseRegistrarContractAddress
        : undefined // eslint-disable-line no-undef
    )
}
